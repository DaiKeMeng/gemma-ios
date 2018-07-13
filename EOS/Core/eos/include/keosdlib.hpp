
#include <boost/algorithm/string.hpp>
#include <boost/filesystem/path.hpp>

#include <map>
#include <chrono>
#include <eosio/chain/transaction.hpp>
#include <eosio/chain/exceptions.hpp>
#include <eosio/chain/name.hpp>
#include <eosio/chain/config.hpp>
#include <eosio/chain/asset.hpp>
#include <eosio/chain/chain_id_type.hpp>
#include <eosio/chain/types.hpp>
#include <boost/algorithm/string.hpp>

#include <fc/crypto/hex.hpp>
#include <fc/variant.hpp>
#include <fc/io/datastream.hpp>
#include <fc/io/json.hpp>
#include <fc/io/console.hpp>
#include <fc/exception/exception.hpp>
#include <fc/variant_object.hpp>
#include <fc/io/json.hpp>
#include <fc/real128.hpp>
#include <fc/crypto/base58.hpp>
#include <fc/crypto/aes.hpp>


namespace fc { class variant; }
using namespace std;
using namespace eosio::chain;

namespace eosio{
    namespace chain_apis {
        class read_only {
            // using chain = eosio::chain;
        public:
            struct get_info_results {
                string                  server_version;
                chain::chain_id_type    chain_id;
                uint32_t                head_block_num = 0;
                uint32_t                last_irreversible_block_num = 0;
                chain::block_id_type    last_irreversible_block_id;
                chain::block_id_type    head_block_id;
                fc::time_point          head_block_time;
                account_name            head_block_producer;
                
                uint64_t                virtual_block_cpu_limit = 0;
                uint64_t                virtual_block_net_limit = 0;
                
                uint64_t                block_cpu_limit = 0;
                uint64_t                block_net_limit = 0;
                //string                  recent_slots;
                //double                  participation_rate = 0;
            };
        };
    }//namespace chain_api
} // namespace eosio
FC_REFLECT(eosio::chain_apis::read_only::get_info_results,
           (server_version)(chain_id)(head_block_num)(last_irreversible_block_num)(last_irreversible_block_id)(head_block_id)(head_block_time)(head_block_producer)(virtual_block_cpu_limit)(virtual_block_net_limit)(block_cpu_limit)(block_net_limit) )


namespace eosio {
    struct plain_keys {
        fc::sha512                            checksum;
        // map<public_key_type,private_key_type> keys;
        pair<public_key_type,private_key_type> key;
    };
    struct wallet_data
    {
        vector<char>              cipher_keys; /** encrypted keys */
    };
    
    // using chain = eosio::chain;
    // struct get_info_results {
    //     std::string                  server_version;
    //     chain::chain_id_type    chain_id;
    //     uint32_t                head_block_num = 0;
    //     uint32_t                last_irreversible_block_num = 0;
    //     chain::block_id_type    last_irreversible_block_id;
    //     chain::block_id_type    head_block_id;
    //     fc::time_point          head_block_time;
    //     account_name            head_block_producer;
    
    //     uint64_t                virtual_block_cpu_limit = 0;
    //     uint64_t                virtual_block_net_limit = 0;
    
    //     uint64_t                block_cpu_limit = 0;
    //     uint64_t                block_net_limit = 0;
    //     //string                  recent_slots;
    //     //double                  participation_rate = 0;
    // };
    
    class keosdlib {
        
    public:
        
        
        // needed by koofrank
        std::pair<std::string, std::string> createKey(const std::string& key_type) {
            std::string upper_key_type = boost::to_upper_copy<std::string>(key_type);
            // return eosio::wallet::wallet_manager::create_key(key_type);
            if(upper_key_type!="R1")
                upper_key_type = "K1";// as default
            
            chain::private_key_type priv_key;
            if(upper_key_type == "K1")
                priv_key = fc::crypto::private_key::generate<fc::ecc::private_key_shim>();
            else if(upper_key_type == "R1")
                priv_key = fc::crypto::private_key::generate<fc::crypto::r1::private_key_shim>();
            else{
                return std::make_pair("?", "?");
            }
            auto public_key = priv_key.get_public_key();
            return std::make_pair((std::string)public_key, (std::string)priv_key);
        }
        
        
        // // Import key
        // void importKey(const std::string& name, const std::string& wif_key) {
        //     walletManager.import_key(name, wif_key);
        // }
        
        // needed by koofrank
        std::string get_private_key(const std::string& cipher, const std::string& password){
            // return eosio::wallet::wallet_manager::get_private_key(password, cipher_keys);
            try{
                if(password.size() == 0)return "";
                std::string cipherstr = "\"" + cipher + "\"";
                auto cipher_keys =fc::json::from_string(cipherstr).as< vector<char> >();
                auto pw = fc::sha512::hash(password.c_str(), password.size());
                vector<char> decrypted = fc::aes_decrypt(pw, cipher_keys);
                auto pk = fc::raw::unpack<plain_keys>(decrypted);
                if(pk.checksum == pw) return (std::string)pk.key.second;
                return "?";
            }catch(...){
                return "";
            }
        }
        
        // needed by koofrank
        std::string get_cypher(const std::string& password, const std::string& priv_key){
            // return eosio::wallet::wallet_manager::get_cipher(password, priv_key);
            plain_keys data;
            wallet_data wada;
            // data.keys = _keys;
            // data.key = _keys;
            // pair<public_key_type,private_key_type>   tmpkey;
            chain::private_key_type priv(priv_key);
            data.key.first = priv.get_public_key();
            data.key.second = priv;
            // data.key = tmpkey;
            data.checksum = fc::sha512::hash( password.c_str(), password.size() );
            auto plain_txt = fc::raw::pack(data);
            // vector<char> cipher_keys = fc::aes_encrypt( data.checksum, plain_txt );
            wada.cipher_keys = fc::aes_encrypt( data.checksum, plain_txt );
            // string cipher = fc::json::to_pretty_string( wada );
            std::string cipher_base = fc::json::to_pretty_string( wada.cipher_keys );
            // string cipher;
            // cipher.clear();
            // cipher.assign(wada.cipher_keys.begin(),wada.cipher_keys.end());
            std::string cipher(cipher_base.begin()+1, cipher_base.end() - 1);
            return cipher;
        }
        // Sign transaction
        std::string signTransaction(const std::string& trxstr, const std::string& priv_key_str, const std::string& chain_id_str){
            auto trx = fc::json::from_string(trxstr).as<chain::signed_transaction>();
            auto priv_key = chain::private_key_type(priv_key_str);
            auto chain_id = fc::json::from_string(chain_id_str).as<chain::chain_id_type>();
            trx.sign(priv_key, chain_id);
            return fc::json::to_string(trx);
        }
        std::string signTransaction(const std::string& priv_key_str, const std::string& contract, const std::string& senderstr, const std::string& recipientstr, const std::string& amountstr,
                                    const std::string& memo, const std::string& infostr, const std::string& abistr , uint32_t max_cpu_usage_ms, uint32_t max_net_usage_words , uint32_t tx_expiration = 30  ){
            // return eosio::wallet::wallet_manager::sign_transaction(priv_key_str, contract, senderstr, recipientstr, amountstr,
            // memo, infostr, abistr ,  max_cpu_usage_ms,  max_net_usage_words ,  tx_expiration  );
            // chain::bytes abi;
            // std::copy( abistr.begin(), abistr.end(), std::back_inserter(abi));
            auto abi = fc::json::from_string("\"" + abistr + "\"").as<bytes>();
            auto actions = {create_transfer(contract, senderstr, recipientstr,chain::asset::from_string(amountstr), memo, abi)};
            chain::signed_transaction trx;
            trx.actions = std::forward<decltype(actions)>(actions);
            auto info = fc::json::from_string(infostr).as<eosio::chain_apis::read_only::get_info_results>();
            auto ref_block_id =info.last_irreversible_block_id;
            auto chain_id = info.chain_id;
            
            trx.set_reference_block(ref_block_id);
            // if(!trx.verify_reference_block(ref_block_id)){
            // trx.ref_block_num = info.last_irreversible_block_num;
            // }
            trx.max_net_usage_words = max_net_usage_words;
            trx.max_cpu_usage_ms = max_cpu_usage_ms;
            trx.expiration = info.head_block_time + fc::seconds(tx_expiration);
            auto priv_key = chain::private_key_type(priv_key_str);
            // sign_transaction(trx,priv_key,chain_id );
            trx.sign(priv_key, chain_id);
            return fc::json::to_string(trx);
            //        chain::packed_transaction ptrx(trx,chain::packed_transaction::none);
            //        return fc::json::to_string(ptrx);
        }
        std::string create_abi_req(const std::string& code, const std::string& action, const std::string& from, const std::string& to, const std::string& quantity, const std::string& memo){
            // return eosio::wallet::wallet_manager::create_abi(code, action, from, to, quantity, memo);
            auto args = fc::mutable_variant_object
            ("from", chain::name(from))
            ("to", chain::name(to))
            ("quantity", chain::asset::from_string(quantity))
            ("memo", memo);
            
            auto request_json_variant = fc::mutable_variant_object
            ("code", code)
            ("action", action)
            ("args", args);
            return fc::json::to_string(request_json_variant);
        }
        
        
    private:
        chain::action create_transfer(const std::string& contract, const chain::name& sender, const chain::name& recipient,
                                      chain::asset amount, const std::string& memo, chain::bytes abi) {
            auto transfer = fc::mutable_variant_object
            ("from", chain::name(sender))
            ("to", chain::name(recipient))
            ("quantity", amount)
            ("memo", memo);
            
            auto args = fc::mutable_variant_object
            ("code", contract)
            ("action", "transfer")
            ("args", transfer);
            
            // auto result = call(json_to_bin_func, args);
            
            return chain::action {
                vector<chain::permission_level>{{sender,config::active_name}} ,
                contract, "transfer", abi
            };
        }
    };
    
    
} // namespace eosio
// FC_REFLECT(eosio::get_info_results,
// (server_version)(chain_id)(head_block_num)(last_irreversible_block_num)(last_irreversible_block_id)(head_block_id)(head_block_time)(head_block_producer)(virtual_block_cpu_limit)(virtual_block_net_limit)(block_cpu_limit)(block_net_limit) )

FC_REFLECT( eosio::plain_keys, (checksum)(key) )

FC_REFLECT( eosio::wallet_data, (cipher_keys) )
