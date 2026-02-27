import { createPublicClient, http, ContractFunctionExecutionError } from 'viem';
import { mainnet } from 'viem/chains';

export class BaseContractAdapter {
    private client;
    private address: `0x${string}`;
    private abi: any[];

    constructor(address: `0x${string}`, abi: any[]) {
        if (!abi || abi.length === 0) {
            throw new Error('Contract ABI is required');
        }
        if (address === '0x0000000000000000000000000000000000000000') {
            throw new Error('Contract address is not configured');
        }
        this.address = address;
        this.abi = abi;
        this.client = createPublicClient({
            chain: mainnet,
            transport: http()
        });
    }

    async retryCall<T>(fn: () => Promise<T>, retries = 3): Promise<T> {
        try {
            return await fn();
        } catch (error) {
            if (retries > 0 && error instanceof ContractFunctionExecutionError) {
                await new Promise(r => setTimeout(r, 1000));
                return this.retryCall(fn, retries - 1);
            }
            throw error;
        }
    }

    async readState(functionName: string, args: any[] = []) {
        return this.retryCall(() => this.client.readContract({
            address: this.address,
            abi: this.abi,
            functionName,
            args
        }));
    }
}
