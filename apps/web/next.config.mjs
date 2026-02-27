/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,
    transpilePackages: ['@peerswap/shared', '@peerswap/base-adapter', '@peerswap/stacks-adapter'],
};

export default nextConfig;
