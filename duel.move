module duel::game {
    use aptos_framework::timestamp;
    use std::string::{Self, String};
    use aptos_framework::coin::{Self, Coin, BurnCapability, FreezeCapability, MintCapability};

    use std::signer;

    
    struct Duel has key, store {
        // the player who initiated the duel
        player: address,
        // the player who accepted the duel
        opponent: address,
        // the amount of coins wagered by the player
        wager: Coin<DuelToken>,
        // the player's card
        player_card: CARD,
    }

    struct CARD has key, store, copy {
        power: u64,
        multiplier: u64,
        name: String,
        description: String,
    }

    struct DuelToken {}

    struct Capabilities has key {
        burn_capability: BurnCapability<DuelToken>,
        freeze_capability: FreezeCapability<DuelToken>,
        mint_capability: MintCapability<DuelToken>,
    }

    const ERR_UNAUTHORIZED: u64 = 0;
    const ERR_INCORRECT_OPPONENT: u64 = 1;
    const ERR_INSUFFICIENT_FUNDS: u64 = 2;

    public entry fun initialize(deployer: &signer) {
        assert!(signer::address_of(deployer) == @duel, ERR_UNAUTHORIZED);
        
        let name = string::utf8(b"Duel Token");
        let symbol = string::utf8(b"DTK");
        let decimals = 8;

        let (burn_capability, freeze_capability, mint_capability) =
            coin::initialize<DuelToken>(deployer, name, symbol, decimals, false);

        move_to(deployer, Capabilities { burn_capability, freeze_capability, mint_capability });
    }

    // Users can name and create their own cards!
    public entry fun mint_card(player: &signer, name: String, description: String) {
        let random_power = timestamp::now_microseconds() % 10;
        let random_multiplier = timestamp::now_seconds() % 4;
        move_to(player, CARD {
            power: random_power,
            multiplier: random_multiplier,
            name,
            description,
        })
    }

   /* public entry fun duel_player1(player1: &signer, player2: address, wager: u64, card: &mut CARD) {
        assert!(signer::address_of(player1) != player2, ERR_UNAUTHORIZED);
        assert!(coin::balance<DuelToken>(signer::address_of(player1)) >= wager, ERR_INSUFFICIENT_FUNDS);

        move_to(player1, Duel {
            player: signer::address_of(player1),
            opponent: player2,
            wager: coin::withdraw<DuelToken>(player1, wager),
            player_card: *card,
        })
    }

    
    public entry fun duel_player2(player2: &signer, player1: address, wager: u64, card: &mut CARD, duel: Duel) {
        assert!(coin::balance<DuelToken>(signer::address_of(player2)) >= wager, ERR_INSUFFICIENT_FUNDS);
        assert!(player1 == duel.player, ERR_INCORRECT_OPPONENT);

        let player2_wager = coin::withdraw<DuelToken>(player2, wager);
        
        let player1_net_power = duel.player_card.power * duel.player_card.multiplier;
        let player2_net_power = card.power * card.multiplier;

        let win_sum = player1_net_power + player2_net_power;

        let random_winner = timestamp::now_microseconds() % win_sum;

        //coin::merge<DuelToken>(&mut player2_wager, duel.wager);
        //let player1_wager = coin::withdraw(&mut duel.wager);
        //let player1_wager = coin::withdraw(player1, &mut duel.wager);
        let player1_wager = coin::withdraw(player2, &mut duel.wager);
        let player1_wager = coin::withdraw(player2, duel.wager, duel.wager.value);
        coin::merge(&mut player2_wager, player1_wager);
        

        if (random_winner <= player1_net_power) {
            duel.player_card.power = duel.player_card.power + card.power;
            coin::deposit<DuelToken>(player1, player2_wager);
        } else {
            card.power = card.power + duel.player_card.power;
            coin::deposit<DuelToken>(signer::address_of(player2), player2_wager);
        }
    }*/
    public entry fun duel_player1(player1: &signer, player2: address, wager: u64, card: &mut CARD) {
        assert!(signer::address_of(player1) != player2, ERR_UNAUTHORIZED);
        assert!(coin::balance<DuelToken>(signer::address_of(player1)) >= wager, ERR_INSUFFICIENT_FUNDS);

        move_to(player1, Duel {
            player: signer::address_of(player1),
            opponent: player2,
            wager: coin::withdraw<DuelToken>(player1, wager),
            player_card: *card,
        })
    }

    public entry fun duel_player2(player2: &signer, player1: address, wager: u64, card: &mut CARD, duel: Duel) {
        assert!(coin::balance<DuelToken>(signer::address_of(player2)) >= wager, ERR_INSUFFICIENT_FUNDS);
        assert!(player1 == duel.player, ERR_INCORRECT_OPPONENT);

        let player2_wager = coin::withdraw<DuelToken>(player2, wager);
        let player1_net_power = duel.player_card.power * duel.player_card.multiplier;
        let player2_net_power = card.power * card.multiplier;

        let win_sum = player1_net_power + player2_net_power;
        let random_winner = timestamp::now_microseconds() % win_sum;

        
        let player1_wager_value = duel.wager.value(); // Assuming there's a value() method to get the amount
        let player1_wager = coin::withdraw<DuelToken>(player2, player1_wager_value);

        coin::merge(&mut player2_wager, player1_wager);

        if (random_winner <= player1_net_power) {
            duel.player_card.power = duel.player_card.power + card.power;
            coin::deposit<DuelToken>(player1, player2_wager);
        } else {
            card.power = card.power + duel.player_card.power;
            coin::deposit<DuelToken>(signer::address_of(player2), player2_wager);
        }
    }

    // Mint duel tokens to wager in games!
    public entry fun mint_token(player: &signer, amount: u64) acquires Capabilities {
        let cap = borrow_global<Capabilities>(@duel);

        if (!coin::is_account_registered<DuelToken>(signer::address_of(player))){
            coin::register<DuelToken>(player);
        };

        let coins = coin::mint<DuelToken>(amount, &cap.mint_capability);
        coin::deposit<DuelToken>(signer::address_of(player), coins);
    }
}