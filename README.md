# Prepare Images for SSD

These tools help you to prepare the images you have annotated with `webscale-bounding-box` for SSD-training.
Currently, there are two scripts:

* `prepare.js`, which does the actual preparation and is the main script
* `fix-annotation-errors.js`, which lets you fix annotation errors if they occur

## Installation & Dependencies

Please make sure that you have `Node` and `npm` installed.
Afterwards, run 
```
npm install
```


## PREPARE.JS

Please run `node server.js` to see usage information.

## FIX-ANNOTATION-ERRORS.JS

This script is capable of fixing the following errors:

* Missing IDs

To use it, run:
```
node fix-annotation-errors.js --dir <DIRECTORY>
```

It has the following properties:

* `--dir`: The path to the directory where the annotation data (the `.json` files) lay
