% Copyright 2025 The MathWorks, Inc.
function exampleProcess(pm)
    %-----------------------------------------------------------------------------------------------
    arguments
        pm padv.ProcessModel {mustBeNonempty}
    end
    %-----------------------------------------------------------------------------------------------
    findModels = padv.builtin.query.FindModels(Name="ModelsQuery");
    %-----------------------------------------------------------------------------------------------
    %
    % Process: Additional Examples
    % Defines a new example process to group related tasks that demonstrate features like task apps
    %
    %-----------------------------------------------------------------------------------------------
    aep                 = padv.Process('AdditionalExamples');
    aep.Title           = "Additional Examples";
    aep.DescriptionText = "Demonstrate Process Advisor functionalities using a customized process";
    %-----------------------------------------------------------------------------------------------
    %
    % Apps
    % Define task tools that you can associate with tasks to provide additional UI actions
    %
    %-----------------------------------------------------------------------------------------------
    % Example Task App
    % This example task app displays a dialog box by using an App Designer app.
    % The dialog box includes:
    % - A text box showing the relative path to the task iteration artifact
    % - An "Open" button to open the model
    % - A "Help" button that links to the padv.TaskTool reference page
    % The App Designer file, TaskAppDemo.mlapp, is in the project root folder.
    % You can open the file to interactively edit the app in App Designer.
    appOpenModel = padv.TaskTool( ...
        Title        = "Example Task App", ...
        Type         = padv.TaskToolType.TaskApp, ...
        ToolFunction = "TaskAppDemo");
    pm.addTaskTool(appOpenModel);
    %-----------------------------------------------------------------------------------------------
    % Task: Configure example task that iterates over the models in the project
    %-----------------------------------------------------------------------------------------------
    taskExampleTaskApps = padv.Task( "Example Automated Task",...
        Title           = "Example Automated Task", ...
        DescriptionText = "Automated task that features an example of Task Tools", ...
        IterationQuery  = findModels, ...
        Action      = @exampleTaskAction, ...
        InputQueries    = [ ...
            padv.builtin.query.FindModels, ...
            padv.builtin.query.FindComponents]);
    taskExampleTaskApps.TaskTools = appOpenModel;
    % Specifying a task tool for the task allows you to open the task app from Process Advisor.
    % To open the task app, point to one of the task iterations, open the task options menu (...),
    % and select "Example Task App".
    pm.addProcess(aep);
    registerTasksAndAddToProcess(pm, aep, taskExampleTaskApps);
end
%###################################################################################################
function registerTasksAndAddToProcess(processModel, process, tasks)
    %-----------------------------------------------------------------------------------------------
    arguments
        processModel (1,1) padv.ProcessModel {mustBeNonempty}
        process      (1,1) padv.Process      {mustBeNonempty}
        tasks              padv.Task         {mustBeNonempty, mustBeVector}
    end
    %-----------------------------------------------------------------------------------------------
    for i = 1:numel(tasks)
        processModel.registerTask(tasks(i));
        process.addTask(tasks(i));
    end
    %-----------------------------------------------------------------------------------------------
end
%###################################################################################################
function taskResult = exampleTaskAction(~)
    taskResult = padv.TaskResult;
end
%###################################################################################################
