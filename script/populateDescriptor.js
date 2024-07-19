const fs = require('fs');
const path = require("path");
const ImageData = require("../files/image-data-v2.json");
const { dataToDescriptorInput } = require('./utils/dataToDescriptorInput');

function generateDescriptorInput() {
  const { bgcolors, palette, images } = ImageData;
  const { bodies, accessories, heads, glasses } = images;

  const bodiesPage = dataToDescriptorInput(bodies.map(({ data }) => data));
  const headsPage = dataToDescriptorInput(heads.map(({ data }) => data));
  const glassesPage = dataToDescriptorInput(glasses.map(({ data }) => data));
  const accessoriesPage = dataToDescriptorInput(accessories.map(({ data }) => data));

  const combinedPages = {
    bodiesPage,
    headsPage,
    glassesPage,
    accessoriesPage,
  };

  const jsonString = JSON.stringify(combinedPages, null, 2);

  const FILE = path.join(__dirname, "../", "files", "descriptors2.json");

  fs.writeFileSync(FILE, jsonString, 'utf-8');
  // fs.writeFileSync('../files/output.json', jsonString, 'utf8');
  console.log('JSON file generated successfully.');
}

function main() {
  generateDescriptorInput();
}

try {
  main();
} catch (error) {
  console.error(error);
  process.exitCode = 1;
}