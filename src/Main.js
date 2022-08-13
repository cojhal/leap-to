import fs from "fs";
import os from "os";

export const getArgs = () => process.argv.slice(2);
export const getHomedir = () => os.homedir();

export const retrieve = (file) => () => {
  const contents = fs.readFileSync(file, { encoding: "utf-8" });
  return JSON.parse(contents);
};

export const store = (data) => (file) => () => {
  const contents = JSON.stringify(data);
  fs.writeFileSync(file, contents, { encoding: "utf-8" });
};
