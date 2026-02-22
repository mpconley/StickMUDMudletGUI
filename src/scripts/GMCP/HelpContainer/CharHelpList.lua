selected_help_topic = nil

-- CSS for category buttons
local categoryButtonCSS = [[
    QLabel {
        background-color: #2a2a35;
        border: 1px solid #4a4a55;
        border-radius: 4px;
        padding: 2px;
    }
    QLabel::hover {
        background-color: #3a3a45;
        border: 1px solid #6a6a75;
    }
]]

local categoryButtonSelectedCSS = [[
    QLabel {
        background-color: #3a3a55;
        border: 2px solid #7a7aff;
        border-radius: 4px;
        padding: 2px;
    }
]]

-- CSS for help topic labels
local helpTopicCSS = [[
    QLabel {
        background-color: transparent;
        padding: 2px 4px;
    }
    QLabel::hover {
        background-color: rgba(100,100,150,50);
    }
]]

-- Storage for dynamically created elements
GUI.HelpCategoryLabels = GUI.HelpCategoryLabels or {}
GUI.HelpTopicRows = GUI.HelpTopicRows or {}
GUI.HelpTopicLabels = GUI.HelpTopicLabels or {}

function on_helplabel_press(category)
    selected_help_topic = category
    CharHelpList()
end

-- Helper to clean up old elements
local function cleanupHelpElements()
    -- Hide and remove old topic labels
    for _, label in pairs(GUI.HelpTopicLabels) do
        if label and label.hide then
            label:hide()
        end
    end
    GUI.HelpTopicLabels = {}
    
    -- Hide and remove old topic rows
    for _, row in pairs(GUI.HelpTopicRows) do
        if row and row.hide then
            row:hide()
        end
    end
    GUI.HelpTopicRows = {}
    
    -- Hide old category labels
    for _, label in pairs(GUI.HelpCategoryLabels) do
        if label and label.hide then
            label:hide()
        end
    end
    GUI.HelpCategoryLabels = {}
    
    -- Hide old scrollbox
    if GUI.HelpTopicsScrollBox then
        GUI.HelpTopicsScrollBox:hide()
        GUI.HelpTopicsScrollBox = nil
    end
end

function CharHelpList()
    -- Check if GMCP Char.Help.List data is available
    if not gmcp or not gmcp.Char or not gmcp.Char.Help or not gmcp.Char.Help.List then
        cleanupHelpElements()
        return
    end

    local help_list = gmcp.Char.Help.List
    local tkeys = {}

    -- Clean up previous elements
    cleanupHelpElements()

    -- Populate and sort category keys
    for k in pairs(help_list) do
        table.insert(tkeys, k)
    end
    table.sort(tkeys)

    -- Calculate layout - categories take 5% height each
    local num_categories = #tkeys
    local category_height = 5
    local scrollbox_height = 100 - (num_categories * category_height)
    local current_y = 0

    -- Set default selected topic if none
    if selected_help_topic == nil or not help_list[selected_help_topic] then
        selected_help_topic = tkeys[1]
    end

    -- Create category labels and scrollbox
    for i, category in ipairs(tkeys) do
        -- Sort topics within this category
        table.sort(help_list[category], function(v1, v2) return v1 < v2 end)

        -- Create category label
        local labelName = "HelpCategory_" .. category
        GUI.HelpCategoryLabels[category] = Geyser.Label:new({
            name = "GUI." .. labelName,
            x = 0,
            y = current_y .. "%",
            width = "100%",
            height = category_height .. "%"
        }, GUI.HelpContainer)

        -- Style based on selection
        if selected_help_topic == category then
            GUI.HelpCategoryLabels[category]:setStyleSheet(categoryButtonSelectedCSS)
        else
            GUI.HelpCategoryLabels[category]:setStyleSheet(categoryButtonCSS)
        end

        GUI.HelpCategoryLabels[category]:echo(
            "<center><font size=\"3\" color=\"yellow\">" .. firstToUpper(category) .. "</font></center>"
        )
        GUI.HelpCategoryLabels[category]:setClickCallback("on_helplabel_press", category)

        current_y = current_y + category_height

        -- If this is the selected category, create the scrollbox with topics
        if selected_help_topic == category then
            -- Create scrollbox for topics
            GUI.HelpTopicsScrollBox = Geyser.ScrollBox:new({
                name = "GUI.HelpTopicsScrollBox",
                x = 0,
                y = current_y .. "%",
                width = "100%",
                height = scrollbox_height .. "%"
            }, GUI.HelpContainer)

            -- Create a VBox inside the scrollbox for rows
            GUI.HelpTopicsVBox = Geyser.VBox:new({
                name = "GUI.HelpTopicsVBox",
                x = 0,
                y = 0,
                width = "100%",
                height = "100%"
            }, GUI.HelpTopicsScrollBox)

            -- Determine number of columns based on available width
            -- We'll use 3 columns by default, but could adapt based on layout
            local topics = help_list[category]
            local num_topics = #topics
            local cols = 3
            local rows_needed = math.ceil(num_topics / cols)
            local row_height = 22  -- Fixed height per row

            local topic_index = 1
            for row_num = 1, rows_needed do
                -- Create HBox for this row
                local rowName = "HelpTopicRow_" .. row_num
                GUI.HelpTopicRows[row_num] = Geyser.HBox:new({
                    name = "GUI." .. rowName,
                    h_policy = Geyser.Fixed,
                    height = row_height
                }, GUI.HelpTopicsVBox)

                -- Add topic labels to this row
                for col = 1, cols do
                    if topic_index <= num_topics then
                        local topic = topics[topic_index]
                        local labelKey = row_num .. "_" .. col
                        
                        GUI.HelpTopicLabels[labelKey] = Geyser.Label:new({
                            name = "GUI.HelpTopicLabel_" .. labelKey
                        }, GUI.HelpTopicRows[row_num])

                        GUI.HelpTopicLabels[labelKey]:setStyleSheet(helpTopicCSS)
                        GUI.HelpTopicLabels[labelKey]:echo(
                            string.format(
                                [[<font size="2" color="cyan">%s</font> <a href="send:help %s"><font size="2" color="magenta">?</font></a>]],
                                topic, topic
                            )
                        )
                        
                        topic_index = topic_index + 1
                    else
                        -- Empty placeholder for alignment
                        local labelKey = row_num .. "_" .. col
                        GUI.HelpTopicLabels[labelKey] = Geyser.Label:new({
                            name = "GUI.HelpTopicLabel_" .. labelKey
                        }, GUI.HelpTopicRows[row_num])
                        GUI.HelpTopicLabels[labelKey]:setStyleSheet([[background-color: transparent;]])
                    end
                end
            end

            current_y = current_y + scrollbox_height
        end
    end

    if selected_console ~= "HelpContainer" then
        on_menu_box_press("BoxPlayers")
    end
end
