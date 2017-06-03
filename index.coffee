glob = require 'glob'
args = require('minimist')(process.argv.slice(2))
path = require 'path'
fs = require 'fs'

console.log 'prepare-images-for-ssd'

printUsage = ->
	console.log ''
	console.log 'Usage:'
	console.log ' --targetDir <path>                 - folder where the prepared images will be copied into'
	console.log ' --sourceDir <path>                 - folder where the image dataset is'
	console.log ' --label <string>                   - what label the selected images get applied'
	console.log ' --output <default pascalVoc>       - how the output data is to be formatted'
	console.log ' --maxNumberOfImages <default 100>  - the maximum number of images that are selected'
	console.log ' --valPercentage <default 15>       - percentage of selected images that are used as a validation set'
	console.log ' --filterManualBbox <default true>  - only allow images that have a manually annotated bounding box'
	return

requiredArguments = ['targetDir', 'sourceDir', 'label']
for requiredArgument in requiredArguments
	unless args[requiredArgument]?
		console.error "ERROR: argument '#{requiredArgument}' is required"
		printUsage()
		return

args.output ?= 'pascalVoc'
args.maxNumberOfImages ?= 100
args.valPercentage ?= 15
args.filterManualBbox ?= true

loadAllImages = (dir) ->
	dir = path.normalize dir
	files = glob.sync '*.json', {cwd: dir}
	files.sort()

	images = []
	for file in files
		fullpath = path.join dir, file
		images.push JSON.parse fs.readFileSync fullpath, 'utf8'

	return images


images = loadAllImages(args.sourceDir)
console.log "Found #{images.length} in source folder"