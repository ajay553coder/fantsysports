 module my_addr::FantasySports {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;

   
    struct FantasyLeague has store, key {
        entry_fee: u64,         
        total_prize_pool: u64,    
        participants: vector<address>, 
        is_active: bool,          
        max_participants: u64,   
    }

   
    struct PlayerScore has store, key {
        total_score: u64,        
        league_address: address,   
    }

  
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

  
    public fun join_league(
        participant: &signer, 
        league_owner: address
    ) acquires FantasyLeague {
        let participant_addr = signer::address_of(participant);
        let league = borrow_global_mut<FantasyLeague>(league_owner);
        
    
        assert!(league.is_active, 1);
        assert!(vector::length(&league.participants) < league.max_participants, 2);
        
        
        let entry_payment = coin::withdraw<AptosCoin>(participant, league.entry_fee);
        coin::deposit<AptosCoin>(league_owner, entry_payment);
        
        
        vector::push_back(&mut league.participants, participant_addr);
        league.total_prize_pool = league.total_prize_pool + league.entry_fee;
        
      
        let player_score = PlayerScore {
            total_score: 0,
            league_address: league_owner,
        };
        move_to(participant, player_score);
    }

}
