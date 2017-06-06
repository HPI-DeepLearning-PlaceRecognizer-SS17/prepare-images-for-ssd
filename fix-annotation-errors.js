args = require('minimist')(process.argv.slice(2));
glob = require('glob');
path = require('path');
fs = require('fs');

var toolInfo = '\n' + 
            '--dir <string> \tDirectory to the annotations that need to be repaired.\tREQUIRED';

var parseArgs = function(){
    if(!('dir' in args)){
        console.error('You must specifiy property --dir.');
        console.log(toolInfo);
        return false;
    }
    return true;
}

var findFiles = function(dir) {
    dir = path.normalize(dir);
    console.log("Going to work with directory", dir);
    files = glob.sync('*.json', {cwd: dir});
    console.log("Found", files.length, "annotations");
    return files.map(function(file) {
        return path.join(dir, file);
    });
}

var loadFile = function(file) {
    // console.info('Loading file', file);
    return JSON.parse(fs.readFileSync(file, 'utf8'));
}
var writeFile = function(file, jsonContent) {
    fs.writeFileSync(file, JSON.stringify(jsonContent));
}

var extractFileId = function(file) {
    var fileName = file.split('/').pop();
    return fileName.substr(0, fileName.length - '.json'.length);
}

var repairFile = function(file) {
    var fileId = extractFileId(file);
    var annotationContent = loadFile(file);
    annotationContent['id'] = fileId;
    writeFile(file, annotationContent);
    console.log('Fixed file with id', fileId);
}

var repairFiles = function(files) {
    for(fileIndex in files) {
        repairFile(files[fileIndex]);
    }
}

if(!parseArgs()){
    return;
}

var dir = args['dir'];
var files = findFiles(dir);
repairFiles(files);