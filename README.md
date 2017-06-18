# Prepare Images for SSD

These tools help you to prepare the images you have annotated with `webscale-bounding-box` for SSD-training.
Currently, there are two scripts:

* `prepare.js`, which does the actual preparation and is the main script
* `fix-annotation-errors.js`, which lets you fix annotation errors if they occur

## Installation & Dependencies

Please make sure that you have `Node` and `npm` installed.
Afterwards, run `npm install`.

## Prepare.js

### Usage

Run `node prepare.js` with the following arguments

```
Usage:
 --targetDir <path>                 - folder where the prepared images will be copied into
 --sourceDir <path>                 - folder where the image dataset is
 --label <string>                   - what label the selected images get applied
 --output <default pascalVoc>       - how the output data is to be formatted
 --maxNumberOfImages <default 200>  - the maximum number of images that are selected
 --valPercentage <default 10>       - percentage of selected images that are used as a validation set
 --filterManualBbox <default true>  - only allow images that have a manually annotated bounding box
```

Example call: 
`node prepare.js --sourceDir "D:\Dropbox\pva-training-set\flickr-parsed\dl-rathaus-berlin" --targetDir "D:\Dropbox\pva-training-set\flickr-parsed\#prepared" --label rathausberlin`

### Dockerfile

There is a Dockerfile to build Prepare.js. Use the script `buildDockerImage.sh` to build it, then you can use the application with docker, e.g.
```
sudo docker run -v /hostPathToImages:/srcImg -v /hostTargetDir:/dstImg \
     prepare-images-for-ssd --sourceDir "/srcImg/berlinerdom" --targetDir "/dstImg" --label berlinerdom
```

## Fix-annotation-errors.js

(The script should not be needed anymore)

This script is capable of fixing the following errors:

* Missing IDs

To use it, run:
```
node fix-annotation-errors.js --dir <DIRECTORY>
```

It has the following properties:

* `--dir`: The path to the directory where the annotation data (the `.json` files) lay
