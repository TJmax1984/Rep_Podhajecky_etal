function params = getParameters_v2(nDirectories)
%% This function extracts the relevant user provided parameters from a GUI window  
    % Return structure
    params = [];

    % Set window size based on number of directories
    h = 180 + 40*nDirectories;

    fig = uifigure( 'Name','Analysis settings','Position',[300 300 700 h]);

    y = h - 50;
    
    % Directory selectors
    dirFields = gobjects(nDirectories,1);
    textFields = gobjects(nDirectories,1);
    
    for k = 1:nDirectories
    
        uilabel(fig,'Position',[20 y 100 22],'Text',sprintf('Data Path %d:',k));
    
        % Directory field
        dirFields(k) = uieditfield(fig,'text','Position',[130 y 300 22]);
    
        % Browse button
        uibutton(fig,'Text','Browse','Position',[440 y 80 22],'ButtonPushedFcn',@(src,event)browseFolder(dirFields(k)));
    
        % Additional text field
        textFields(k) = uieditfield(fig,'text','Position',[530 y 150 22],'Placeholder','Strain & condition name');
    
        y = y - 40;
    
    end
    
    % Numeric field 1
    uilabel(fig,'Position',[20 y 100 22],'Text','Pixel size (um):');

    num1 = uieditfield(fig,'numeric','Position',[130 y 100 22],'Value',0.1123);


    y = y - 40;

    uilabel(fig,'Position',[20 y 100 22],'Text','No. channels:');

    num2 = uieditfield(fig,'numeric','Position',[130 y 100 22],'Value',1);
    
    % First text field
    uilabel(fig,'Position',[250 y 80 22],'Text','Name ch1:');
    
    text1 = uieditfield(fig,'text','Position',[320 y 120 22],'Value','GFP');
    
    % Second text field
    uilabel(fig,'Position',[460 y 80 22],'Text','Name ch2:');
    
    text2 = uieditfield(fig,'text','Position',[530 y 120 22],'Value','mK');
    
    y = y - 40;


    % First additional numeric field
    uilabel(fig,'Position',[250 y 80 22],'Text','BG ch1:');
    
    num3 = uieditfield(fig,'numeric','Position',[320 y 100 22],'Value',101);
    
    % Second additional numeric field
    uilabel(fig,'Position',[460 y 80 22],'Text','BG ch2:');
    
    num4 = uieditfield(fig,'numeric','Position',[530 y 100 22],'Value',101);

    y = y - 40;



    % OK button
    uibutton(fig,'Text','OK','Position',[300 5 100 30],'ButtonPushedFcn',@finish);

    uiwait(fig)

    % --------------------------------------------------
    function browseFolder(editField)

        d = uigetdir;

        if d ~= 0
            editField.Value = d;
        end

    end

    % --------------------------------------------------
    function finish(~,~)

        params.pixel_size = num1.Value;
        params.no_channels = num2.Value;
        params.name_ch1 = text1.Value;
        params.name_ch2 = text2.Value;
        params.BG_ch1 = num3.Value;
        params.BG_ch2 = num4.Value;

        params.directories = cell(nDirectories,1);
        params.conditions = cell(nDirectories,1);
        
        for j = 1:nDirectories
        
            params.directories{j} = dirFields(j).Value;
            params.conditions{j} = textFields(j).Value;
        
        end

        uiresume(fig)
        delete(fig)

    end

end