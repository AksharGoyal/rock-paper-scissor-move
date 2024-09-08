/// The `RockPaperScissors` module provides an implementation of the classic Rock-Paper-Scissors game.
/// 
/// The module allows players to start a new game, set their move, and finalize the game results. It also
/// provides functions to retrieve the player's move, the computer's move, the game results, and the
/// player's and computer's scores.
///
/// The game is implemented using a `Game` resource that is stored per-player. The `start_game` function
/// creates a new `Game` resource for the player, and the other functions in the module operate on this
/// resource.

address player_address {

module RockPaperScissors {
    use std::signer;
    use aptos_framework::randomness;
    use std::vector;
    use std::string::{String, utf8};
    // use std::debug;

    const ROCK: u8 = 1;
    const PAPER: u8 = 2;
    const SCISSORS: u8 = 3;

    struct Game has key {
    player: address,
    player_move: u8,   
    computer_move: u8,
    result: String,
    player_score: u64,
    computer_score: u64
}

    public entry fun start_game(account: &signer) {
        let player = signer::address_of(account);

        let game = Game {
            player,
            player_move: 0,
            computer_move: 0,
            result: utf8(b"NONE"),
            player_score: 0,
            computer_score: 0,
        };

        move_to(account, game);
    }

    public entry fun set_player_move(account: &signer, player_move: u8) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        game.player_move = player_move;
    }

    #[randomness]
    entry fun randomly_set_computer_move(account: &signer) acquires Game {
        /// The `randomly_set_computer_move` function is marked with the `#[randomness]` attribute, which means
        /// it will use the on-chain randomness source to generate a random move for the computer.
        randomly_set_computer_move_internal(account);
    }

    public(friend) fun randomly_set_computer_move_internal(account: &signer) acquires Game {
        let move_vector: vector<u8> = vector::empty();
        vector::push_back(&mut move_vector, ROCK);
        vector::push_back(&mut move_vector, PAPER);
        vector::push_back(&mut move_vector, SCISSORS);
        let game = borrow_global_mut<Game>(signer::address_of(account));
        let random_number = randomness::u8_range(1, 4);
        game.computer_move = random_number;
    }

    public entry fun finalize_game_results(account: &signer) acquires Game {
    let game = borrow_global_mut<Game>(signer::address_of(account));
    game.result = determine_winner(game.player_move, game.computer_move);

    if (game.result == utf8(b"Player won!")) {
        game.player_score = game.player_score + 1;
    } else if (game.result == utf8(b"Computer won!")) {
        game.computer_score = game.computer_score + 1;
    }
}

    public entry fun reset_game(account: &signer) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        game.player_move = 0;
        game.player_score = 0;
        game.computer_move = 0;
        game.computer_score = 0;
        game.result = utf8(b"NONE");
    }

    fun determine_winner(player_move: u8, computer_move: u8): String {
    if (player_move == ROCK && computer_move == SCISSORS) {
        utf8(b"Player won!")
    } else if (player_move == PAPER && computer_move == ROCK) {
        utf8(b"Player won!")
    } else if (player_move == SCISSORS && computer_move == PAPER) {
        utf8(b"Player won!")
    } else if (player_move == computer_move) {
        utf8(b"It's a draw!")
    } else {
        utf8(b"Computer won!")
    }
}

    #[view]
    public fun get_player_move(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).player_move
    }

    #[view]
    public fun get_computer_move(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).computer_move
    }

    #[view]
    public fun get_game_results(account_addr: address): String acquires Game {
        borrow_global<Game>(account_addr).result
    }

    #[view]
public fun get_player_score(account_addr: address): u64 acquires Game {
    borrow_global<Game>(account_addr).player_score
}

    #[view]
public fun get_computer_score(account_addr: address): u64 acquires Game {
    borrow_global<Game>(account_addr).computer_score
}


}
}