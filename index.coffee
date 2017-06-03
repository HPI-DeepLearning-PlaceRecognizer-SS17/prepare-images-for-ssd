glob = require 'glob'
args = require('minimist')(process.argv.slice(2))
path = require 'path'
fs = require 'fs'
fsextra = require 'fs-extra'
mkdirp = require 'mkdirp'

console.log 'prepare-images-for-ssd'

printUsage = ->
	console.log ''
	console.log 'Usage:'
	console.log ' --targetDir <path>                 - folder where the prepared images will be copied into'
	console.log ' --sourceDir <path>                 - folder where the image dataset is'
	console.log ' --label <string>                   - what label the selected images get applied'
	console.log ' --output <default pascalVoc>       - how the output data is to be formatted'
	console.log ' --maxNumberOfImages <default 200>  - the maximum number of images that are selected'
	console.log ' --valPercentage <default 10>       - percentage of selected images that are used as a validation set'
	console.log ' --filterManualBbox <default true>  - only allow images that have a manually annotated bounding box'
	return

requiredArguments = ['targetDir', 'sourceDir', 'label']
for requiredArgument in requiredArguments
	unless args[requiredArgument]?
		console.error "ERROR: argument '#{requiredArgument}' is required"
		printUsage()
		return

args.output ?= 'pascalVoc'
args.maxNumberOfImages ?= 200
args.valPercentage ?= 10
args.filterManualBbox ?= true

loadAllImages = (dir) ->
	dir = path.normalize dir
	files = glob.sync '*.json', {cwd: dir}
	files.sort()

	console.log "Loadig #{files.length} found images..."

	images = []
	for file in files
		fullpath = path.join dir, file
		images.push JSON.parse fs.readFileSync fullpath, 'utf8'

	return images

args.sourceDir = path.resolve args.sourceDir
args.targetDir = path.resolve args.targetDir

images = loadAllImages(args.sourceDir)
console.log 'Images loaded.'

if args.filterManualBbox is true
	console.log 'Filtering for images that have a manually annotated bounding box'

	images = images.filter (image) ->
		return image.manualAnnotation?.bbox?

	console.log "After filtering, #{images.length} images are left"

console.log "Restricting images to a maximum of #{args.maxNumberOfImages} images"
images.length = Math.min args.maxNumberOfImages, images.length

valPercentage = args.valPercentage / 100
numberOfValidationImages = Math.max 1, Math.round(images.length * valPercentage)
numberOfTrainingImages = Math.max 1, images.length - numberOfValidationImages

console.log "There will be #{numberOfTrainingImages} training images and #{numberOfValidationImages} validation images"
if numberOfValidationImages + numberOfValidationImages > images.length
	console.error 'ERROR: not enough images!'
	return

trainingDir = path.join args.targetDir, 'training'
validationDir = path.join args.targetDir, 'validation'

mkdirp.sync args.targetDir
mkdirp.sync trainingDir
mkdirp.sync validationDir

# Write labels
labels = []
labelsFile = path.join args.targetDir, 'labels.json'
if fs.existsSync labelsFile
	labels = JSON.parse fs.readFileSync labelsFile, 'utf8'

if labels.indexOf(args.label) < 0
	labels.push args.label

fs.writeFileSync labelsFile, JSON.stringify labels, true, 2

_transferImage = (image, targetDir) ->
	# Find the matching jpeg file - the exact file name may differ depending on the downloaded size
	images = glob.sync "#{image.id}*.jpg", {cwd: args.sourceDir}

	if images.length is 0
		console.warn "Unable to find jpg for image #{image.id}"
		return

	fsextra.copySync(
		path.join args.sourceDir, images[0]
		path.join targetDir, "#{image.id}.jpg"
	)

	# Extract useful information out of the json
	# ToDo: support automatically generated bbox, choose best one
	# ToDo: handle case if there is no bbox
	distJson = {
		id: image.id
		label: args.label
		boundingBox: image.manualAnnotation.bbox
	}
	jsonFile = path.join targetDir, "#{image.id}.json"
	fs.writeFileSync jsonFile, JSON.stringify distJson, true, 2

trainingImages = images.splice 0, numberOfTrainingImages
validationImages = images

for image in trainingImages
	_transferImage image, trainingDir

for image in validationImages
	_transferImage image, validationDir

