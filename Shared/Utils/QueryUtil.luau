

local function QueryCallback<a>(parent: Instance, selector: string, callback: (instance: a)-> ())
    for _, value in parent:QueryDescendants(selector) do
        callback(value)
    end
end

return {
    Callback = QueryCallback,
}