import React, { useEffect, useState } from 'react';
import './App.css';
import { Types, AptosClient } from 'aptos';

const gameAddress = '0x61315d864828f1508e77744a0f05c26bb10dafbe8a669b894eefb2114016e7f6'

function App() {
  // Retrieve aptos.account on initial render and store it.
  const [address, setAddress] = useState<string | null>(null);
  const [publicKey, setPublicKey] = useState<string | null>(null);
  const [tokenAmount, setTokenAmount] = useState<string>('0');
  const [cardName, setCardName] = useState<string>('');
  const [cardDescription, setCardDescription] = useState<string>('');
  const [opponentAddress, setOpponentAddress] = useState<string>('');
  const [wager, setWager] = useState<string>('0');
  const [selectedCard, setSelectedCard] = useState<any>(null); // Assuming card is an object. Adjust accordingly.
  const [error, setError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);


  /**
   * 
   * init function
   */
  const init = async () => {
    // connect
    try {
      if (window && (!window.martian)) {
        console.log('Martian not found')
        return { aptos: [], sui: [] };
      }

      const data = await window.martian.connect();

      const { result } = data;
      const address = result.aptos[0].address;
      const publicKey = result.aptos[0].publicKey;
      setAddress(address);
      setPublicKey(publicKey);
    } catch (e) {
      console.log(e);
    }
  }

  useEffect(() => {
    init();
  }, []);

  const mintToken = async (amount: string) => {
    const payload = {
      function: `${gameAddress}::duel::game::mint_token`,
      type_arguments: [],
      arguments: [amount],
      sender: address
    }
    console.log(payload);

    const result = await window.martian.generateSignAndSubmitTransaction(address, payload);
    console.log(result);
  }

  const mintCard = async (name: string, description: string) => {
    const payload = {
        function: `${gameAddress}::duel::game::mint_card`,
        type_arguments: [],
        arguments: [name, description],
        sender: address // The sender's address, which is you (the player)
    }
    console.log(payload);

    const result = await window.martian.generateSignAndSubmitTransaction(address, payload);
    console.log(result);
  }
  const initiateDuel = async (opponentAddress: string, wagerAmount: string) => {
    const wager = Number(wagerAmount);
    if (!Number.isSafeInteger(wager)) {
        setError("Invalid wager amount");
        return;
    }

    const payload = {
        function: `${gameAddress}::duel::game::duel_player1`,
        type_arguments: [],
        arguments: [opponentAddress, wager.toString(), selectedCard], // Assume selectedCard contains appropriate CARD structure
        sender: address // The sender's address, which is you (player1)
    }

    try {
      setIsLoading(true);

      const result = await window.martian.generateSignAndSubmitTransaction(address, payload);

      if (result && result.success) {
        setSuccessMessage("Successfully initiated a duel!");
      } else {
        setError("Failed to initiate a duel. Please try again.");
      }
    } catch (e) {
      setError("An error occurred while trying to initiate a duel.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="App">
      <p>Account Address: <code>{address}</code></p>
      <p>Account Public Key: <code>{publicKey}</code></p>
      <input type="text" placeholder="Token Amount" value={tokenAmount} onChange={(v) => setTokenAmount(v.target.value)} />
      <button onClick={() => mintToken(tokenAmount)}>Mint Tokens!</button>

      <input type="text" placeholder="Card Name" value={cardName} onChange={(v) => setCardName(v.target.value)} />
      <input type="text" placeholder="Card Description" value={cardDescription} onChange={(v) => setCardDescription(v.target.value)} />
      <button onClick={() => mintCard(cardName, cardDescription)}>Mint Card!</button>

      <h2>Duel</h2>
      <input type="text" placeholder="Opponent Address" value={opponentAddress} onChange={(v) => setOpponentAddress(v.target.value)} />
      <input type="text" placeholder="Wager Amount" value={wager} onChange={(v) => setWager(v.target.value)} />
      <button onClick={() => initiateDuel(opponentAddress, wager)}>Initiate Duel</button>

      {isLoading && <p>Loading...</p>}
      {error && <div className="message error">{error}</div>}
      {successMessage && <div className="message success">{successMessage}</div>}
    </div>
  );





}

export default App;
// ...rest of the code...

