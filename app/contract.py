from django.conf import settings
from web3 import Web3
from solc import compile_standard
import json
from app import models


def deploy():
    source = open(settings.CONTRACT_PATH).read()
    compiled_sol = compile_standard({
        "language": "Solidity",
        "sources": {
            "contract.sol": {
                "content": source
            }
        },
        "settings":
            {
                "outputSelection": {
                    "*": {
                        "*": [
                            "metadata", "evm.bytecode"
                            , "evm.bytecode.sourceMap"
                        ]
                    }
                }
            }
    })
    w3 = Web3(Web3.HTTPProvider(settings.NODE_URL))
    w3.eth.defaultAccount = w3.eth.accounts[0]
    bytecode = compiled_sol['contracts']['contract.sol']['Oracle']['evm']['bytecode']['object']
    abi = json.loads(compiled_sol['contracts']['contract.sol']['Oracle']['metadata'])['output']['abi']
    C = w3.eth.contract(abi=abi, bytecode=bytecode)
    tx_hash = C.constructor().transact()
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    contract_model = models.Contract(bytecode=bytecode, abi=json.dumps(abi), tx_hash=tx_hash, address=tx_receipt.contractAddress, deployed=True)
    contract_model.save()


def get_current_info():
    current_contract = models.Contract.get_current()
    w3 = Web3(Web3.HTTPProvider(settings.NODE_URL))
    w3.eth.defaultAccount = w3.eth.accounts[0]
    contract = w3.eth.contract(
        address=current_contract.address,
        abi=json.loads(current_contract.abi)
    )
    info = {
        "proposed": get_proposed_values(contract, w3),
        "value": get_value(contract, w3),
        "interval": get_interval(contract, w3),
        # "last_update_timestamp": get_last_update_timestamp(contract, w3)
    }
    return info


def get_proposed_values(contract, w3):
    # tx_hash = contract.functions.getProposedValues().transact()
    # tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
    res = contract.functions.getProposedValues().call()
    return res


def get_value(contract, w3):
    # tx_hash = contract.functions.retrieve().transact()
    res = contract.functions.retrieve().call()
    return res
    # tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)


def get_interval(contract, w3):
    res = contract.functions.interval().call()
    return res
    # tx_hash = contract.functions.interval().transact()
    # tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)


# def get_last_update_timestamp(contract, w3):
#     tx_hash = contract.functions.Retrieve().transact()
#     tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)
