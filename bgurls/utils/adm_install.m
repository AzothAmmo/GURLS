function path = adm_install()

        basePath = bgurls_root;
        basePath = fullfile(basePath,'adm');

        srcdir 	= fullfile(basePath, 'src');
        bindir 	= fullfile(basePath, 'bin');

        mex('CXXFLAGS=$CXXFLAGS -std=c++11', '-outdir', bindir, fullfile(srcdir, 'admSetup.cpp'));
        mex('CXXFLAGS=$CXXFLAGS -std=c++11', '-outdir', bindir, fullfile(srcdir, 'admDismiss.cpp'));
        mex('CXXFLAGS=$CXXFLAGS -std=c++11', '-outdir', bindir, 	fullfile(srcdir, 'getWork.cpp'), ...
                                fullfile(srcdir, 'lockManagement.cpp'),...
                                fullfile(srcdir, 'workManagement.cpp'));
        mex('CXXFLAGS=$CXXFLAGS -std=c++11', '-outdir', bindir, 	fullfile(srcdir, 'reportWork.cpp'), ...
                                fullfile(srcdir, 'lockManagement.cpp'),...
                                fullfile(srcdir, 'workManagement.cpp'));

        addpath(bindir);
