const ReplicatedStorage = game:GetService("ReplicatedStorage")


const ModuleLoader = require(ReplicatedStorage.Shared.Modules.Loaders.ModuleLoader)


const Folder = script.Services
const Extension = 'Service'

ModuleLoader.Fire(Folder,Extension)