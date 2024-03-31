"use client"
import Link from 'next/link';
import {useState, useEffect} from "react"
import detectEthereumProvider from '@metamask/detect-provider'
import Web3 from 'web3';

export default function Navbar() {
  const [isConnected, setIsConnected] = useState(false);
  const [web3Api, setWeb3Api] = useState({
    provider: null,
    web3: null
  });
  const [account, setAccount] = useState();

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

  return (
    <nav className="relative flex w-full flex-wrap items-center justify-between bg-zinc-50 py-2 shadow-dark-mild dark:bg-neutral-700 lg:py-4 cursor-pointer">
      <div className="flex w-full flex-wrap items-center justify-between px-3">
        <div className="ms-3">
          <Link className="text-xl font-medium text-black dark:text-white" href="/">CSC</Link>
        </div>
        
        <ol className="list-reset ms-2 flex">
          <li className="text-black/60 transition duration-200 hover:text-black/80">
            <Link href="/tenders">Tenders</Link>
          </li>
          <li>
            <span className="mx-3 text-black/60 dark:text-white/60">
              /
            </span>
          </li>
          <li className="text-black/60 transition duration-200 hover:text-black/80">
            <Link href="/companies">Companies</Link>
          </li>
          <li>
            <span className="mx-3 text-black/60 dark:text-white/60">
              /
            </span>
          </li>
          <li className="text-black/60 transition duration-200 hover:text-black/80">
            <Link href="/materials">Materials</Link>
          </li>
          <li>
            <span className="mx-3 text-black/60 dark:text-white/60">
              /
            </span>
          </li>
          <li className="text-black/60 transition duration-200 hover:text-black/80">
            <Link href="/createtender">Create Tender</Link>
          </li>
          <li>
            <span className="mx-3 text-black/60 dark:text-white/60">
              /
            </span>
          </li>
          <li className="text-black/60 transition duration-200 hover:text-black/80">
            <Link href="/addcompany">Add Company</Link>
          </li>
        </ol>

        <div className="inline-block rounded border-2 border-neutral-800 px-3 pb-[6px] pt-2 text-xs font-bold leading-normal text-neutral-800 transition duration-150 ease-in-out hover:border-neutral-800 hover:bg-neutral-100 hover:text-neutral-800 focus:border-neutral-800 focus:bg-neutral-100 focus:text-neutral-800 focus:outline-none focus:ring-0 active:border-neutral-900 active:text-neutral-900 motion-reduce:transition-none dark:text-neutral-600 dark:hover:bg-neutral-900 dark:focus:bg-neutral-900">
          {isConnected ? `${account}` : "you are not connected"}
        </div>
      </div>
    </nav>
  )
}