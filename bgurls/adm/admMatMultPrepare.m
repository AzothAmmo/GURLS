function [] = admMatMultPrepare(X,Y, jobFileName)
		jobStruct = struct;
		jobStruct.XPath = X.Path;
		jobStruct.YPath = Y.Path;
		jobStruct.stateFileName = [pwd() '/state_' datestr(now,30)];
        
        f = fopen(jobStruct.stateFileName, 'w');
		for s = 1:X.NumBlocks
            fwrite(f, s, 'int32');
            fwrite(f, 0, 'int32');
        end
        fwrite(f, -1, 'int32');
        fwrite(f, 0, 'int32');
		fclose(f);
		save(jobFileName,'jobStruct');
		pause(5);
