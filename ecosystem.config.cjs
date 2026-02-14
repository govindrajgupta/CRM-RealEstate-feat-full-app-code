// PM2 Ecosystem Configuration for CRM Real Estate
// Run with: pm2 start ecosystem.config.cjs

module.exports = {
    apps: [
        {
            name: 'crm-api',
            cwd: './apps/api',
            script: 'index.ts',
            interpreter: '/root/.bun/bin/bun',
            env: {
                NODE_ENV: 'production',
                PORT: 3001,
            },
            instances: 1,
            autorestart: true,
            max_memory_restart: '300M',
            error_file: './logs/api-error.log',
            out_file: './logs/api-out.log',
            merge_logs: true,
        },
        {
            name: 'crm-frontend',
            cwd: './apps/frontend',
            script: 'node_modules/.bin/next',
            args: 'start -p 3000',
            env: {
                NODE_ENV: 'production',
                PORT: 3000,
            },
            instances: 1,
            autorestart: true,
            max_memory_restart: '400M',
            error_file: './logs/frontend-error.log',
            out_file: './logs/frontend-out.log',
            merge_logs: true,
        },
    ],
};
