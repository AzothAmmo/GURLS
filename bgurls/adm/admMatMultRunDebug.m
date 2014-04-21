function [out] = admMatMultRunDebug(jobFileName, opt, both, numJobsToDo)
% opt is the bgurls options struct
% both is a flag that determines whether both the "X" and "Y"
% bigarrays are transformed using the polynomial mapping in opt.
% if Y happens to be equal to the training data, both should be set to 1
		jf = load(jobFileName);
		X = bigarray.Obj(jf.jobStruct.XPath, 'mat');
		Y = bigarray.Obj(jf.jobStruct.YPath, 'mat');
		fLock = admSetup(jf.jobStruct.stateFileName);
		
		blockID = NO_WORK;
        
        jobs_done = 0;
		
		while (blockID ~= JOB_DONE)
				blockID = getWork(jf.jobStruct.stateFileName, fLock);
				if ~exist(jf.jobStruct.stateFileName,'file')
					fprintf('Unable to read "%s"\n', jf.jobStruct.stateFileName);
					blockID = JOB_DONE;
				end	
				switch blockID
					case JOB_DONE
						fprintf('Job Completed!\r');
					case NO_WORK
						fprintf('Node out of work\r');
						pause(10);
					case FINALIZE_JOB
						fprintf('Finalizing Job\r');
						finalizeJob(jf.jobStruct.stateFileName, X.NumBlocks, jobFileName);
						reportWork(jf.jobStruct.stateFileName, fLock, blockID);
					otherwise
						fprintf(2, 'Taking care of job: %d\r\n', blockID);
						d = multBlock(X,Y,double(blockID), opt, both);
						save([jf.jobStruct.stateFileName '_' num2str(blockID)], 'd','-v7.3');
						reportWork(jf.jobStruct.stateFileName, fLock, blockID);
                        
                        jobs_done = jobs_done + 1;
                        if jobs_done >= numJobsToDo
                            break;
                        end
				end
		end
		
		admDismiss(fLock);
end		
function d = multBlock(X,Y,blockID, opt, both)
		bX = X.ReadBlockTransform(blockID, opt.RegressStruct);
        
        if both
            bY = Y.ReadBlockTransform(blockID, opt.RegressStruct);
        else
            bY = Y.ReadBlock(blockID);
        end
        
		d = bX*bY';
end

function [] = finalizeJob(stateFileName, nB, jobFileName)
		t = load([stateFileName '_' num2str(1)]);
		data = zeros(size(t.d));
		for i = 1:nB
			bName = [stateFileName '_' num2str(i)];
			t = load(bName);
			delete([bName '.mat']);
			data = data + t.d;
		end
		save(jobFileName, 'data','-v7.3');
end	


