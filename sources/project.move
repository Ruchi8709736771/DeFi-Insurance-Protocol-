module DeFiInsurance::Policy {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing an insurance policy.
    struct Policy has store, key {
        premium: u64,       // Premium paid for the policy
        is_active: bool,   // Status of the policy
    }

    /// Function to create a new insurance policy by depositing a premium.
    public fun create_policy(owner: &signer, premium: u64) {
        let policy = Policy {
            premium,
            is_active: true,
        };
        move_to(owner, policy);

        // Transfer the premium from the owner to the contract's account
        let premium_amount = coin::withdraw<AptosCoin>(owner, premium);
        let contract_address = address_of(DeFiInsurance);
        coin::deposit<AptosCoin>(&contract_address, premium_amount);
    }

    /// Function for a policyholder to file a claim against their policy.
    public fun file_claim(policyholder: &signer) acquires Policy {
        let policy = borrow_global_mut<Policy>(address_of(policyholder));

        // Ensure the policy is active
        assert!(policy.is_active, 1);

        // Deactivate the policy upon claim
        policy.is_active = false;

        // Logic to process the claim (e.g., transferring funds) can be added here
        // For simplicity, we will just transfer the premium back to the policyholder
        let claim_amount = policy.premium;
        let contract_address = address_of(DeFiInsurance);
        let claim_funds = coin::withdraw<AptosCoin>(&contract_address, claim_amount);
        coin::deposit<AptosCoin>(policyholder, claim_funds);
    }
}
