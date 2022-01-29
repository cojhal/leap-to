const fs = require('fs');

exports.getArgs = () => process.argv.slice(2)
exports.getDirname = () => __dirname;

exports.retrieve = file => () => {
    const contents = fs.readFileSync(file, { encoding: "utf-8" })
    return JSON.parse(contents);
}
exports.store = data => file => () => {
    const contents = JSON.stringify(data);
    fs.writeFileSync(file, contents, { encoding: "utf-8" })
}