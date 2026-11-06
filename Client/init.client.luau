
const ReplicatedStorage = game:GetService("ReplicatedStorage")


const ModuleLoader = require(ReplicatedStorage.Shared.Modules.Loaders.ModuleLoader)


const Folder = script.Controllers
const Extension = 'Controller'

ModuleLoader.Fire(Folder,Extension)