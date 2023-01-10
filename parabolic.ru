use stellar_sdk::{Account, Asset, KeyPair, Transaction};

struct ParabolicExchange {
    owner_account: Account,
    base_asset: Asset,
    counter_asset: Asset,
}

impl ParabolicExchange {
    fn new(owner_account: Account, base_asset: Asset, counter_asset: Asset) -> Self {
        Self {
            owner_account,
            base_asset,
            counter_asset,
        }
    }
    fn sell(&self, amount: i64, seller_secret: &str, buyer_public: &str) -> Transaction {
        let seller_keypair = KeyPair::from_secret(seller_secret).unwrap();
        let buyer_keypair = KeyPair::from_public_key(buyer_public).unwrap();
        let base_amount = Asset::new(amount, self.base_asset.clone());
        let counter_amount = self.owner_account
            .get_max_amount(base_amount, self.counter_asset.clone())
            .unwrap();
        let mut transaction = Transaction::new_sale(
            &seller_keypair,
            base_amount,
            self.counter_asset.clone(),
            counter_amount,
            self.owner_account.keypair(),
        );
        transaction.add_time_bounds(30, 60);
        transaction
    }

    fn buy(&self, amount: i64, buyer_secret: &str, seller_public: &str) -> Transaction {
        let buyer_keypair = KeyPair::from_secret(buyer_secret).unwrap();
        let seller_keypair = KeyPair::from_public_key(seller_public).unwrap();
        let counter_amount = Asset::new(amount, self.counter_asset.clone());
        let base_amount = self.owner_account
            .get_max_amount(counter_amount, self.base_asset.clone())
            .unwrap();
        let mut transaction = Transaction::new_sale(
            &seller_keypair,
            base_amount,
            self.counter_asset.clone(),
            counter_amount,
            self.owner_account.keypair(),
        );
        transaction.add_time_bounds(30, 60);
        transaction
    }
}
