contract;

use std::{
    address::Address,
    assert::assert,
    chain::auth::{AuthError, msg_sender},
    constants::BASE_ASSET_ID,
    context::{call_frames::msg_asset_id, msg_amount},
    contract_id::ContractId,
    identity::Identity,
    option::Option,
    result::Result,
    revert::revert,
    storage::{StorageMap, StorageVec},
    token::transfer_to_output,
    vec::Vec,
};

use multisig_lib::Multisig;

struct Transaction {
    recipient: Address,
    amount: u64,
    executed: bool,
    confitmations: u64,
}

storage {
    //Base asset balance
    balance: u64 = 0,
    //Mutex for constructor
    initialised: bool = false,
    //Allows checking is address is owner
    is_owner: StorageMap<Address,bool> = StorageMap {},
    //Number of confirmations in order for a transaction to be executed
    required_confirmations: u64 = 0,
    //List of submitted transactions
    transactions_list: StorageVec<Transaction> = StorageVec {},
    //Is a given tx confirmed by a given owner. tx_index, address => bool
    is_confirmed: StorageMap<(u64,Address), bool> = StorageMap {},
}

impl Multisig for Contract {
    //Constructor
     #[storage(read, write)]fn constructor(owners: Vec<Address>, required_confirmations: u64) {
        //Check that constructor has not been called before
        if storage.initialised == true {
            revert(0);
        }
        //Check that the number of owners is valid
        if owners.len() < 1 {
            revert(0);
        }
        //Check that the number of confirmations if valid
        if required_confirmations < 1 ||  required_confirmations > owners.len() {
            revert(0);
        }
        //Set info for each owner
        let mut i = 0;
        while i < owners.len() {
            //get owner
            let owner = owners.get(i);
            match owner {
                Option::None => {
                    revert(0)
                },
                Option::Some(owner) => {
                    //Check that owner address is unique
                    if storage.is_owner.get(owner) {
                        revert(0)
                    }
                    //Set info
                    storage.is_owner.insert(owner, true);
                },
            }
            i += 1;
        }
        //Set number of required confirmations before a transaction can be executed
        storage.required_confirmations = required_confirmations;
        //Set initialised to true, preventing constructor from being called again
        storage.initialised = true;
    }

    //All other func must first check  storage.initialised == true

    //Receive funds
    #[storage(read, write)]fn receive_funds() {
        //Check if multisig has been setup
        if storage.initialised == false {
            revert(0);
        } 
        if msg_asset_id() == BASE_ASSET_ID {
            // If we received `BASE_ASSET_ID` then keep track of the balance.
            // Otherwise, we're receiving other native assets and don't care
            // about our balance of tokens.
            storage.balance = storage.balance + msg_amount();
        }
    }

    //Owner can submit a transaction for review
    #[storage(read, write)]fn submit_tx(recipient: Address, amount: u64) {
        //Check if multisig has been setup
        if storage.initialised == false {
            revert(0);
        } 
        //Get msg_sender, check that its an owner
        let sender: Result<Identity, AuthError> = msg_sender();
        if let Identity::Address(sender_address) = sender.unwrap() {
            assert(storage.is_owner.get(sender_address));

            //Get next tx_index
            let tx_index = storage.transactions_list.len();

            //Set and submit tx
            let mut tx = Transaction {
                recipient: recipient,
                amount: amount,
                executed: false,
                confitmations: 1, //Confirmation of the submitter
            };
            storage.transactions_list.push(tx);

            //Update confirmation map for sender
            storage.is_confirmed.insert((tx_index, sender_address), true);

        } else {
            revert(0);
        }
    }

    //
}


