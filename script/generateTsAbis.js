const fs = require("fs");
const path = require("path");
const prettier = require("prettier");

function getDirectories(path) {
  return fs.readdirSync(path).filter(function(file) {
    return fs.statSync(path + "/" + file).isDirectory();
  });
}

function getFiles(path) {
  return fs.readdirSync(path).filter(function(file) {
    return fs.statSync(path + "/" + file).isFile();
  });
}

function getAbiOfContract(contractName) {
  const currentPathToArtifacts = path.join(
    __dirname,
    "..",
    `out/${contractName}.sol`
  );
  const artifactJson = JSON.parse(
    fs.readFileSync(`${currentPathToArtifacts}/${contractName}.json`)
  );

  return artifactJson.abi;
}

function loadExistingContracts(filePath) {
  if (!fs.existsSync(filePath)) return {};

  const content = fs.readFileSync(filePath, 'utf8');
  try {
    // Extracting the JSON-like content from the TypeScript file
    const jsonContentMatch = content.match(/export const contracts = (\{[\s\S]*?\});/);
    if (!jsonContentMatch || jsonContentMatch.length < 2) return {};

    // Evaluating the JSON-like content to an object
    const contractsObject = eval('(' + jsonContentMatch[1] + ')');
    return contractsObject;
  } catch (error) {
    console.error('Error parsing existing contracts.ts:', error);
    return {};
  }
}

function mergeContracts(existingContracts, newContracts) {
  Object.keys(newContracts).forEach(chainId => {
    if (!existingContracts[chainId]) existingContracts[chainId] = {};
    Object.assign(existingContracts[chainId], newContracts[chainId]);
  });

  return existingContracts;
}


function main() {
  const currentPathToBroadcast = path.join(__dirname, "..", "broadcast/Deploy.s.sol");
  const currentPathToDeployments = path.join(__dirname, "..", "deployments");
  const chains = getDirectories(currentPathToBroadcast);
  const Deploymentchains = getFiles(currentPathToDeployments);

  var deployments = {};
  var contractsAddresses = {};
  const newContracts = {
    // This object will be filled with the new contract addresses as before
  };
  var contractNames = [];

  Deploymentchains.forEach((chain) => {
    if (!chain.endsWith(".json")) return;
    chain = chain.slice(0, -5);
    var deploymentObject = JSON.parse(
      fs.readFileSync(`${currentPathToDeployments}/${chain}.json`)
    );
    deployments[chain] = deploymentObject;
  });

  const ABI_DIR = path.join(__dirname, "../../", "nextjs", "contracts", "abis");
  const CONTRACTS_FILE = path.join(__dirname, "../../", "nextjs", "contracts", "contracts.ts");
  const INDEX_FILE = path.join(ABI_DIR, "index.ts");

  if (!fs.existsSync(ABI_DIR)) {
    fs.mkdirSync(ABI_DIR, { recursive: true });
  }

  const allAbiFileNames = fs.readdirSync(ABI_DIR).filter(file => file.endsWith(".ts"));

  // const existingAbis = loadExistingAbis(INDEX_FILE);
  const existingAbis = {};

  allAbiFileNames.forEach((abiFile) => {
    const contractName = path.basename(abiFile, ".ts");
    if(contractName !== "index") {
      existingAbis[contractName] = true;
    }
  });


  chains.forEach((chain) => {
    contractsAddresses[chain] = {};

    var broadCastObject = JSON.parse(
      fs.readFileSync(`${currentPathToBroadcast}/${chain}/run-latest.json`)
    );
    var transactionsCreate = broadCastObject.transactions.filter(
      (transaction) => transaction.transactionType == "CREATE"
    );

    transactionsCreate.forEach((transaction) => {
      const contractName = deployments[chain][transaction.contractAddress] || transaction.contractName;
      contractNames.push(contractName); // Update contract names list

      // Only create and export the ABI if it doesn't already exist
      // if (!existingAbis[contractName]) { 
        const abi = getAbiOfContract(transaction.contractName);
        const abiFilePath = path.join(ABI_DIR, `${contractName}.ts`);

        fs.writeFileSync(
          abiFilePath,
          prettier.format(
            `export const ${contractName}Abi = ${JSON.stringify(abi, null, 2)};`,
            { parser: "typescript" }
          )
        );

        // Track the new ABI that was added
        existingAbis[contractName] = true; 
      // }

      contractsAddresses[chain][contractName] = transaction.contractAddress;
    });


    // json files
    const contractsForChain = contractsAddresses[chain];

    // Create a JSON object to store the contract data
    const chainData = {};
    for (const contractName in contractsForChain) {
      chainData[contractName] = contractsForChain[contractName];
    }

    // Generate the filename and ensure output directory exists
    const outputDir = path.join(__dirname, "deployedContracts");
    const outputFilePath = path.join(outputDir, `${chain}.json`);

    let existingData = {};
    if (fs.existsSync(outputFilePath)) {
        existingData = JSON.parse(fs.readFileSync(outputFilePath, "utf8"));
    }
    const updatedData = { ...existingData, ...contractsAddresses[chain] };

    // Write JSON to file
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir);
    }
    fs.writeFileSync(outputFilePath, JSON.stringify(updatedData, null, 2)); 

    // // Write the JSON data to the file
    // const jsonData = JSON.stringify(chainData, null, 2);  // Pretty formatting
    // fs.writeFileSync(outputFilePath, jsonData);
  });

  // updateIndexFile(INDEX_FILE, contractNames, existingAbis); 
  updateIndexFile(INDEX_FILE, Object.keys(existingAbis));

  let existingContracts = loadExistingContracts(CONTRACTS_FILE);
  const updatedContracts = mergeContracts(existingContracts, contractsAddresses);
  const updatedContent = `export const contracts = ${JSON.stringify(updatedContracts, null, 2)};`;

  // Write contracts addresses
  fs.writeFileSync(CONTRACTS_FILE, prettier.format(updatedContent, { parser: "typescript" }));
  // fs.writeFileSync(CONTRACTS_FILE, 
  //   prettier.format(`export const contracts = ${JSON.stringify(contractsAddresses, null, 2)};`, {
  //     parser: "typescript",

  //   })
  // );

  // let uniqueExportContracts = [...new Set(contractNames)];
  // // Create index.ts for ABI exports
  // const exportStatements = uniqueExportContracts
  //   .sort()
  //   .map(name => `export { ${name}Abi } from './${name}';`)
  //   .join('\n');

  // fs.writeFileSync(INDEX_FILE, prettier.format(exportStatements, {parser: "typescript"}));
}

function loadExistingAbis(indexFile) {
  const existingAbis = {};
  if (!fs.existsSync(indexFile)) return existingAbis;

  const indexContent = fs.readFileSync(indexFile, 'utf8');

  indexContent.split('\n').forEach(line => {
    const match = line.match(/export \{ (\w+)Abi } from '\.\/(\w+)'/);
    if (match) {
      existingAbis[match[2]] = true; // Record existing ABI names
    }
  });

  return existingAbis;
}

function updateIndexFile(indexFile, contractNames) {
  const exportStatements = contractNames
    .sort()
    .map(name => `export { ${name}Abi } from './${name}';`)
    .join('\n');

  fs.writeFileSync(indexFile, prettier.format(exportStatements, { parser: "typescript" }));
}

// function updateIndexFile(indexFile, contractNames, existingAbis) {
//   let indexContent = fs.existsSync(indexFile) ? fs.readFileSync(indexFile, 'utf8') : '';

//   const newExportStatements = contractNames
//     .filter(name => !existingAbis[name]) // Select only new contracts
//     .sort()
//     .map(name => `export { ${name}Abi } from './${name}';`)
//     .join('\n');

//   if (indexContent) {
//     indexContent = `${indexContent}\n${newExportStatements}`; // Append new exports
//   } else {
//     indexContent = newExportStatements; // Create new content 
//   }

//   fs.writeFileSync(indexFile, prettier.format(indexContent, {parser: "typescript"}));
// }

try {
  main();
} catch (error) {
  console.error(error);
  process.exitCode = 1;
}
