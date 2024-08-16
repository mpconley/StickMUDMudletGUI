-- Define the CSS for the training list display
GUI.CharTrainingListCSS = CSSMan.new([[
	qproperty-wordWrap: true;
    qproperty-alignment: 'AlignTop';
]])

function on_trainniglabel_press(category) CharTrainingList() end

function CharTrainingList()
    local training_total = gmcp.Char.Training.List
    local skill_max_length = 0
    local max_count = 0

    table.sort(training_total, function(v1, v2) return v1.skill < v2.skill end)

    local trainingList = "<table width=\"100%\">"

    -- Calculate maximum lengths and counts
    for k, v in pairs(training_total) do
        local count = 0

        if string.len(v.name) > skill_max_length then
            skill_max_length = string.len(v.name)
        end

        for i = 0, string.len(v.skill) do
            if string.sub(v.skill, i, i) == "." then
                count = count + 1
            end
        end

        if count > max_count then max_count = count end
    end

    trainingList = trainingList ..
                       "<tr><td><font size=\"3\" color=\"red\">Training</font></td><td><font size=\"3\" color=\"red\">Rank</font></td></tr>"

    -- Construct the training list
    for k, v in pairs(training_total) do
        local count = 0

        for i = 0, string.len(v.skill) do
            if string.sub(v.skill, i, i) == "." then
                count = count + 1
            end
        end

        local color = "<font size=\"3\" color=\"gray\">"
        if count == 0 then
            color = "<font size=\"3\" color=\"magenta\">"
        elseif count == 1 then
            color = "<font size=\"3\" color=\"yellow\">"
        end

        trainingList = trainingList .. "<tr><td>" .. color ..
                           string.rep("&nbsp;", count) .. v.name ..
                           string.rep("&nbsp;",
                                      (skill_max_length + max_count - count -
                                          string.len(v.name))) .. "</font></td>"
        trainingList = trainingList .. "<td>" ..color .. v.rank ..
                           "</font> <font size=\"3\" color=\"cyan\">" .. v.percent ..
                           "</font></td></tr>"
    end

    trainingList = trainingList .. "</table>"

    -- Create the ScrollBox and populate it with the training list
    GUI.CharTrainingListLabel = Geyser.Label:new({
        name = "GUI.CharTrainingListLabel",
        x = 0,
        y = 0,
        width = "100%",
        height = "200%"
    }, GUI.TrainingScrollBox)
    GUI.CharTrainingListLabel:setStyleSheet(GUI.CharTrainingListCSS:getCSS())
    setBackgroundColor("GUI.CharTrainingListLabel", 0, 0, 0)
    GUI.CharTrainingListLabel:echo(trainingList)
end
