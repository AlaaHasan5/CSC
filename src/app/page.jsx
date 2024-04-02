"use client"
import {useState, useEffect} from "react"
import detectEthereumProvider from '@metamask/detect-provider'
import Web3 from 'web3';

export default function Home() {
  const [isConnected, setIsConnected] = useState(false);
  const [web3Api, setWeb3Api] = useState({
    provider: null,
    web3: null
  });

  useEffect(() => {
    const loadProvider = async () => {
      try {
        const provider = await detectEthereumProvider();
        if (provider) {
          providerChanged(provider);
          setWeb3Api({
            provider: provider,
            web3: new Web3(provider)
          });
          setIsConnected(true);
          await provider.request({ method: 'eth_requestAccounts' })
        } else {
          console.error('Please install MetaMask!');
        }
      } catch (error) {
        console.error('Error initializing MetaMask:', error);
      }
    }
    loadProvider();
  },[])

  const [account, setAccount] = useState();

  useEffect(() => {
    const loadAccounts =async () => {
      const accounts = await web3Api.web3.eth.getAccounts();
      setAccount(accounts[0]);
    }
    web3Api.web3 && loadAccounts()
  },[web3Api.web3])

  const providerChanged = (provider) => {
    provider.on("accountsChanged", _ => window.location.reload());
    provider.on("chainChanged", _ => window.location.reload());
  }

  const [centralAuthorityContract, setCentralAuthorityContract] = useState();
  const [createTenderContract, setCreateTenderContract] = useState();
  const [biddingContract, setBiddingContract] = useState();
  const [materialsContract, setMaterialsContract] = useState();
  useEffect(() => {
    const loadContracts = async () => {
      // Paths of json file
      const centralAuthorityContractFile = await fetch('/abis/CentralAuthority.json');
      const createTenderContractFile = await fetch('/abis/CreateTender.json');
      const biddingContractFile = await fetch('/abis/Bidding.json');
      const materialsContractFile = await fetch('/abis/Materials.json');

      // Convert files to JSON
      const centralAuthorityContractJsonFile = await centralAuthorityContractFile.json();
      const createTenderContractJsonFile = await createTenderContractFile.json();
      const biddingContractJsonFile = await biddingContractFile.json();
      const materialsContractJsonFile = await materialsContractFile.json();

      // Get the ABI
      const centralAuthorityAbi = centralAuthorityContractJsonFile.abi;
      const createTenderAbi = createTenderContractJsonFile.abi;
      const biddingAbi = biddingContractJsonFile.abi;
      const materialsAbi = materialsContractJsonFile.abi;

      const networkId = await web3Api.web3.eth.net.getId();
      const centralAuthorityNetworkObject = centralAuthorityContractJsonFile.networks[networkId];
      const createTenderNetworkObject = createTenderContractJsonFile.networks[networkId];
      const biddingNetworkObject = biddingContractJsonFile.networks[networkId];
      const materialsNetworkObject = materialsContractJsonFile.networks[networkId];
      console.log("==============================");
      console.log(networkId);
      console.log("==============================");
      
      if (centralAuthorityNetworkObject && createTenderNetworkObject && biddingNetworkObject && materialsNetworkObject) {
        const centralAuthorityContractAddress = await centralAuthorityContractJsonFile.networks[networkId].address;
        const createTenderContractAddress = await createTenderContractJsonFile.networks[networkId].address;
        const biddingContractAddress = await biddingContractJsonFile.networks[networkId].address;
        const materialsContractAddress = await materialsContractJsonFile.networks[networkId].address;

        const deployedCentralAuthorityContract = await new web3Api.web3.eth.Contract(centralAuthorityAbi, centralAuthorityContractAddress);
        const deployedCreateTenderContract = await new web3Api.web3.eth.Contract(createTenderAbi, createTenderContractAddress);
        const deployedBiddingContract = await new web3Api.web3.eth.Contract(biddingAbi, biddingContractAddress);
        const deployedMaterialsContract = await new web3Api.web3.eth.Contract(materialsAbi, materialsContractAddress);

        setCentralAuthorityContract(deployedCentralAuthorityContract);
        setCreateTenderContract(deployedCreateTenderContract);
        setBiddingContract(deployedBiddingContract);
        setMaterialsContract(deployedMaterialsContract);
      } else {
        window.alert("Please connect your wallet with Ganache")
      }
    }
    web3Api.web3 && loadContracts()
  },[web3Api.web3])

  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-5">
      <div className="inline-block rounded border-2 border-neutral-800 px-3 pb-[6px] pt-2 text-xs font-bold leading-normal text-neutral-800 transition duration-150 ease-in-out hover:border-neutral-800 hover:bg-neutral-100 hover:text-neutral-800 focus:border-neutral-800 focus:bg-neutral-100 focus:text-neutral-800 focus:outline-none focus:ring-0 active:border-neutral-900 active:text-neutral-900 motion-reduce:transition-none dark:text-neutral-600 dark:hover:bg-neutral-900 dark:focus:bg-neutral-900">
        {isConnected ? `${account}` : "you are not connected"}
      </div>
    </main>
  );
}
