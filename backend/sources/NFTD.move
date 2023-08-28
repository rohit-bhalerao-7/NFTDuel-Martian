module duel::game {

  use std::string::{Self, String};
  use aptos_framework::coin::{Self, Coin};

  struct Card has key {
    power: u64,
    multiplier: u64,
    name: String,
    description: String    
  }

  struct DuelToken has key {}

  struct Capabilities has key {
    mint_cap: MintCapability<DuelToken>
  }

  const ERR_INVALID_ADDRESS: u64 = 0;
  const ERR_INSUFFICIENT_FUNDS: u64 = 1;

  public entry fun initialize(account: &signer) {
    let mint_cap = coin::initialize<DuelToken>(account, b"Duel Token", b"DTK", 8, false);
    move_to(account, Capabilities { mint_cap });
  }

  public entry fun create_card(account: &signer, name: String, description: String) {
    let power = rand::random_u64() % 10;
    let multiplier = rand::random_u64() % 4;

    move_to(account, Card {
      power, 
      multiplier,
      name,
      description
    });
  }

  public entry fun mint_tokens(account: &signer, amount: u64) acquires Capabilities {
    assert!(exists<Capabilities>(signer::address_of(account)), ERR_INVALID_ADDRESS);
    
    let cap = borrow_global<Capabilities>(signer::address_of(account));
    let tokens = coin::mint<DuelToken>(amount, &cap.mint_cap);
    coin::deposit(signer::address_of(account), tokens);
  }
}