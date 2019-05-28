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
local sp_comp = in_data["component"]["name"]

local out_data = {
    attachments = {
        {
            fallback = sp_name .. " is experiencing a " .. sp_desc .. " in component '" .. sp_comp .. "'",
            color = colours[sp_indc],
            author_name = sp_name,
            title = sp_desc,
            title_link = sp_link,
            text = sp_desc .. " in " .. sp_comp .. " component",
            fields = {
                {
                    title = "Service",
                    value = sp_name,
                    short = true,
                },
                {
                    title = "Component",
                    value = sp_comp,
                    short = true,
                },
            },
            footer = "Forwarded by foobar.herokuapp.com",
        },
    },
}

local out_json = json.encode(out_data)
ngx.log(0, out_json)
ngx.req.set_body_data(out_json)
