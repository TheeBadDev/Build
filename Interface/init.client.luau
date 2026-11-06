
const ReplicatedStorage = game:GetService("ReplicatedStorage")


const ModuleLoader = require(ReplicatedStorage.Shared.Modules.Loaders.ModuleLoader)


const Folder = script.Screens
const Extension = 'Screen'

ModuleLoader.Fire(Folder,Extension)