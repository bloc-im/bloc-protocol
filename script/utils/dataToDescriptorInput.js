const ethers = require('ethers');
const utils = ethers.utils;
const { deflateRawSync } = require('zlib');


async function printEstimatedCost(factory, gasPrice) {
  const deploymentGas = await factory.signer.estimateGas(
    factory.getDeployTransaction({ gasPrice }),
  );
  const deploymentCost = deploymentGas.mul(gasPrice);
  console.log(
    `Estimated cost to deploy NounsDAOLogicV2: ${utils.formatUnits(deploymentCost, 'ether')} ETH`,
  );
}

function dataToDescriptorInput(data) {
  const abiEncoded = ethers.utils.defaultAbiCoder.encode(['bytes[]'], [data]);
  const encodedCompressed = `0x${deflateRawSync(
    Buffer.from(abiEncoded.substring(2), 'hex'),
  ).toString('hex')}`;

  const originalLength = abiEncoded.substring(2).length / 2;
  const itemCount = data.length;

  return {
    encodedCompressed,
    originalLength,
    itemCount,
  };
}

module.exports = {
  printEstimatedCost,
  dataToDescriptorInput,
};
