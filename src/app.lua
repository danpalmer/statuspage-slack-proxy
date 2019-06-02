local json = require "cjson"
local http = require "resty.http"

-- Global resources
local httpc = http.new()

-- Local request
local body = ngx.req.get_body_data()
local in_data = json.decode(body)
local page_id = in_data["page"]["id"]

-- StatusPage.io Metadata request
local sp_page_uri = "https://" .. page_id .. ".statuspage.io/api/v2/summary.json"
local res, err = httpc:request_uri(sp_page_uri, { method = "GET" })
if not res then
    ngx.say("failed to request: ", err)
    return
end

local page_data = json.decode(res.body)

local colours = {
    none = "#00823B",
    minor = "#FFBF47",
    major = "#DF3034",
    critical = "#DF3034",
}

local sp_name = page_data["page"]["name"]
local sp_desc = in_data["page"]["status_description"]
local sp_link = page_data["page"]["url"]
local sp_indc = in_data["page"]["status_indicator"]
local sp_comp = in_data["component"]

local domain = "statuspage-slack-proxy.herokuapp.com"
local by_line = "Forwarded by <https://" .. domain .. "|" .. domain .. ">"
local unsubscribe = "<" .. in_data["meta"]["unsubscribe"] .. "|Unsubscribe>"
local footer = by_line .. " – " .. unsubscribe

local out_data = {
    attachments = {
        {
            fallback = sp_name .. " is experiencing a " .. sp_desc,
            color = colours[sp_indc],
            author_name = sp_name,
            title = sp_desc,
            title_link = sp_link,
            fields = {
                {
                    title = "Service",
                    value = sp_name,
                    short = true,
                },
                
            },
            footer = footer,
        },
    },
}

if sp_comp ~= json.null then
    local sp_comp_name = sp_comp["name"]
    local sp_comp_desc = sp_comp["description"]

    out_data["attachments"][1]["fallback"] = (
        sp_name .. " is experiencing a " .. sp_desc .. " in component '" .. sp_comp_name .. "'"
    )
    out_data["attachments"][1]["title"] = (
        sp_desc .. " in " .. sp_comp_name .. " component"
    )

    table.insert(
        out_data["attachments"][1]["fields"],
        {
            title = "Component",
            value = sp_comp_name,
            short = true,
        }
    )

    if not (sp_comp_desc == json.null or sp_comp_desc == '')   then
        table.insert(
            out_data["attachments"][1]["fields"],
            {
                title = "Description",
                value = sp_comp_desc,
                short = false,
            }
        )
    end
end

local out_json = json.encode(out_data)
ngx.req.set_body_data(out_json)
