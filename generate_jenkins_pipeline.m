% Copyright 2025 The MathWorks, Inc.
% GitHub Push Hook Test

function generate_jenkins_pipeline()
    workspace = string(getenv('WORKSPACE'));      % Reading Jenkins workspace environment variable
    supportPackageRoot = string(getenv('MW_SUPPORT_PACKAGE_ROOT'));
    relativeProjectPath = string(getenv('MW_RELATIVE_PROJECT_PATH'));
    remoteBuildCacheName = string(getenv('MW_REMOTE_BUILD_CACHE_NAME'));
    pipelineGenDirectory = string(getenv('MW_PIPELINE_GEN_DIRECTORY'));

    localWorkDir = fullfile(workspace, 'work');
    if ~isfolder(localWorkDir)
        mkdir(localWorkDir);
    end

    fprintf('### Setting Simulink FileGenControl to workspace: %s\n', localWorkDir);
    try
        Simulink.fileGenControl('set', ...
            'CacheFolder', localWorkDir, ...
            'CodeGenFolder', localWorkDir, ...
            'createDir', true);
    catch ME
        warning('Initial FileGenControl setup failed. Attempting reset. Error: %s', ME.message);
        Simulink.fileGenControl('reset');
        Simulink.fileGenControl('set', ...
            'CacheFolder', localWorkDir, ...
            'CodeGenFolder', localWorkDir, ...
            'createDir', true);
    end

    cp = openProject("");
    op = padv.pipeline.JenkinsOptions;
    op.AgentLabel = "simulink-test-jenkins-agent-label";
    op.PipelineArchitecture = "SerialStagesGroupPerTask";
    op.GeneratorVersion = 2;
    op.SupportPackageRoot = supportPackageRoot;
    op.GeneratedPipelineDirectory = pipelineGenDirectory;
    op.StopOnStageFailure = true;
    op.RunprocessCommandOptions.GenerateJUnitForProcess = true;
    op.ReportPath = "$PROJECTROOT$/PA_Results/Report/ProcessAdvisorReport";
    op.RelativeProjectPath = relativeProjectPath;
    op.RemoteBuildCacheName = remoteBuildCacheName;

    op.ArtifactServiceMode = 'network';         % network/jfrog/s3/azure_blob
    op.NetworkStoragePath = '/artifactManagement/cacheStorage';
    % op.ArtifactoryUrl = '<JFrog Artifactory url>';
    % op.ArtifactoryRepoName = '<JFrog Artifactory repo name>';
    % op.S3BucketName = '<AWS S3 bucket name>';
    % op.S3AwsAccessKeyID = '<AWS S3 access key id>';
    % op.AzContainerName = '<Azure Blob container name>';
    % op.RunnerType = "container";          % default/container
    % op.ImageTag = '<Docker Image full name>';
    % op.ImageArgs = "<Docker container arguments>";
    
    % Docker image settings
    % op.UseMatlabPlugin = false;
    % op.MatlabLaunchCmd = "xvfb-run -a matlab -batch"; 
    % op.MatlabStartupOptions = "";
    % op.AddBatchStartupOption = false;

    % Forcing rerun (not just icremental build, if changes were detected)
    op.ForceRun = true; 
    padv.pipeline.generatePipeline(op, "CIPipeline");
end