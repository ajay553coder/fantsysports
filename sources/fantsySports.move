 module my_addr::FantasySports {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;

    /// Struct representing a fantasy league
    struct FantasyLeague has store, key {
        entry_fee: u64,           // Entry fee to join the league
        total_prize_pool: u64,    // Total prize pool accumulated
        participants: vector<address>, // List of participants
        is_active: bool,          // League status
        max_participants: u64,    // Maximum number of participants
    }

    /// Struct to store player scores
    struct PlayerScore has store, key {
        total_score: u64,         // Player's total fantasy score
        league_address: address,   // Associated league
    }

    /// Function to create a new fantasy league
    public fun create_league(
        owner: &signer, 
        entry_fee: u64, 
        max_participants: u64
    ) {
        let league = FantasyLeague {
            entry_fee,
            total_prize_pool: 0,
            participants: vector::empty<address>(),
            is_active: true,
            max_participants,
        };
        move_to(owner, league);
    }

    /// Function for users to join a league and contribute entry fee
    public fun join_league(
        participant: &signer, 
        league_owner: address
    ) acquires FantasyLeague {
        let participant_addr = signer::address_of(participant);
        let league = borrow_global_mut<FantasyLeague>(league_owner);
        
        // Check if league is active and not full
        assert!(league.is_active, 1);
        assert!(vector::length(&league.participants) < league.max_participants, 2);
        
        // Transfer entry fee to league owner
        let entry_payment = coin::withdraw<AptosCoin>(participant, league.entry_fee);
        coin::deposit<AptosCoin>(league_owner, entry_payment);
        
        // Add participant and update prize pool
        vector::push_back(&mut league.participants, participant_addr);
        league.total_prize_pool = league.total_prize_pool + league.entry_fee;
        
        // Initialize player score
        let player_score = PlayerScore {
            total_score: 0,
            league_address: league_owner,
        };
        move_to(participant, player_score);
    }
}