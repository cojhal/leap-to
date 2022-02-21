const fs = require('fs');
const os = require('os');

exports.getArgs = () => process.argv.slice(2)
exports.getHomedir = () => os.homedir();

exports.retrieve = file => () => {
    const contents = fs.readFileSync(file, { encoding: "utf-8" })
    return JSON.parse(contents);
}
exports.store = data => file => () => {
    const contents = JSON.stringify(data);
    fs.writeFileSync(file, contents, { encoding: "utf-8" })
}