// OffsetAPI Server
// Node.js + Express API for managing game offsets

const express = require('express');
const cors = require('cors');
const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Database file
const DB_FILE = path.join(__dirname, 'offsets_db.json');

// In-memory cache
let offsetsCache = {
    version: '1.0.0',
    lastUpdate: Date.now(),
    offsets: []
};

// Initialize database
async function initDatabase() {
    try {
        const data = await fs.readFile(DB_FILE, 'utf8');
        offsetsCache = JSON.parse(data);
        console.log('✅ Database loaded successfully');
    } catch (error) {
        console.log('⚠️  No existing database, creating new one...');
        offsetsCache = {
            version: '1.0.0',
            lastUpdate: Date.now(),
            offsets: [
                // Default offsets - ALL SET TO 0x0
                {
                    name: 'GetMatchClientInfo',
                    category: 'anticheat',
                    value: 0x0,
                    description: 'Get client anticheat info',
                    verified: false,
                    timestamp: Date.now()
                },
                {
                    name: 'OnRequestCheckHackBehaviorResFinished',
                    category: 'anticheat',
                    value: 0x0,
                    description: 'Hack behavior check response handler',
                    verified: false,
                    timestamp: Date.now()
                },
                {
                    name: 'RecvAntiDataReq',
                    category: 'anticheat',
                    value: 0x0,
                    description: 'Receive anticheat data from server',
                    verified: false,
                    timestamp: Date.now()
                },
                {
                    name: 'MatchClientInfo_ParseFrom',
                    category: 'anticheat',
                    value: 0x0,
                    description: 'Parse match client info',
                    verified: false,
                    timestamp: Date.now()
                },
                {
                    name: 'PlayerColliderChecker_GetPartByCollider',
                    category: 'aimbot',
                    value: 0x0,
                    description: 'Get body part by collider (aimbot detection)',
                    verified: false,
                    timestamp: Date.now()
                },
                {
                    name: 'AntiAddictionHint',
                    category: 'anticheat',
                    value: 0x0,
                    description: 'Anti-addiction system hint',
                    verified: false,
                    timestamp: Date.now()
                },
                {
                    name: 'PlayerPosition',
                    category: 'esp',
                    value: 0x0,
                    description: 'Player position offset',
                    verified: false,
                    timestamp: Date.now()
                },
                {
                    name: 'PlayerHealth',
                    category: 'player_info',
                    value: 0x0,
                    description: 'Player health value',
                    verified: false,
                    timestamp: Date.now()
                },
                {
                    name: 'PlayerTeamID',
                    category: 'player_info',
                    value: 0x0,
                    description: 'Player team identifier',
                    verified: false,
                    timestamp: Date.now()
                },
                {
                    name: 'WeaponRecoil',
                    category: 'weapon',
                    value: 0x0,
                    description: 'Weapon recoil value',
                    verified: false,
                    timestamp: Date.now()
                }
            ]
        };
        await saveDatabase();
    }
}

// Save database
async function saveDatabase() {
    try {
        await fs.writeFile(DB_FILE, JSON.stringify(offsetsCache, null, 2));
        console.log('💾 Database saved');
    } catch (error) {
        console.error('❌ Error saving database:', error);
    }
}

// Generate API key
function generateApiKey() {
    return crypto.randomBytes(32).toString('hex');
}

// API Routes

// Get all offsets
app.get('/api/offsets', (req, res) => {
    res.json(offsetsCache);
});

// Get offset by name
app.get('/api/offsets/:name', (req, res) => {
    const offset = offsetsCache.offsets.find(o => o.name === req.params.name);
    
    if (offset) {
        res.json(offset);
    } else {
        res.status(404).json({ error: 'Offset not found' });
    }
});

// Get offsets by category
app.get('/api/offsets/category/:category', (req, res) => {
    const offsets = offsetsCache.offsets.filter(o => o.category === req.params.category);
    res.json({ offsets });
});

// Add new offset
app.post('/api/offsets', async (req, res) => {
    const { name, category, value, description } = req.body;
    
    if (!name || !category) {
        return res.status(400).json({ error: 'Name and category are required' });
    }
    
    // Check if offset already exists
    const existing = offsetsCache.offsets.find(o => o.name === name);
    if (existing) {
        return res.status(409).json({ error: 'Offset already exists' });
    }
    
    const newOffset = {
        name,
        category,
        value: value || 0x0,
        description: description || '',
        verified: false,
        timestamp: Date.now()
    };
    
    offsetsCache.offsets.push(newOffset);
    offsetsCache.lastUpdate = Date.now();
    
    await saveDatabase();
    
    res.status(201).json(newOffset);
});

// Update offset
app.put('/api/offsets/:name', async (req, res) => {
    const { value, description, verified } = req.body;
    const offset = offsetsCache.offsets.find(o => o.name === req.params.name);
    
    if (!offset) {
        return res.status(404).json({ error: 'Offset not found' });
    }
    
    if (value !== undefined) offset.value = value;
    if (description !== undefined) offset.description = description;
    if (verified !== undefined) offset.verified = verified;
    offset.timestamp = Date.now();
    
    offsetsCache.lastUpdate = Date.now();
    
    await saveDatabase();
    
    res.json(offset);
});

// Delete offset
app.delete('/api/offsets/:name', async (req, res) => {
    const index = offsetsCache.offsets.findIndex(o => o.name === req.params.name);
    
    if (index === -1) {
        return res.status(404).json({ error: 'Offset not found' });
    }
    
    const deleted = offsetsCache.offsets.splice(index, 1)[0];
    offsetsCache.lastUpdate = Date.now();
    
    await saveDatabase();
    
    res.json({ message: 'Offset deleted', offset: deleted });
});

// Batch update offsets
app.post('/api/offsets/batch', async (req, res) => {
    const { offsets } = req.body;
    
    if (!Array.isArray(offsets)) {
        return res.status(400).json({ error: 'Offsets must be an array' });
    }
    
    let updated = 0;
    let created = 0;
    
    for (const newOffset of offsets) {
        const existing = offsetsCache.offsets.find(o => o.name === newOffset.name);
        
        if (existing) {
            Object.assign(existing, {
                ...newOffset,
                timestamp: Date.now()
            });
            updated++;
        } else {
            offsetsCache.offsets.push({
                ...newOffset,
                timestamp: Date.now(),
                verified: newOffset.verified || false
            });
            created++;
        }
    }
    
    offsetsCache.lastUpdate = Date.now();
    await saveDatabase();
    
    res.json({
        message: 'Batch update complete',
        updated,
        created,
        total: offsetsCache.offsets.length
    });
});

// Reset all offsets to 0x0
app.post('/api/offsets/reset', async (req, res) => {
    offsetsCache.offsets.forEach(offset => {
        offset.value = 0x0;
        offset.verified = false;
        offset.timestamp = Date.now();
    });
    
    offsetsCache.lastUpdate = Date.now();
    await saveDatabase();
    
    res.json({
        message: 'All offsets reset to 0x0',
        count: offsetsCache.offsets.length
    });
});

// Export offsets as JSON
app.get('/api/export', (req, res) => {
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Disposition', 'attachment; filename=offsets.json');
    res.json(offsetsCache);
});

// Import offsets from JSON
app.post('/api/import', async (req, res) => {
    try {
        const { offsets, version } = req.body;
        
        if (!Array.isArray(offsets)) {
            return res.status(400).json({ error: 'Invalid format' });
        }
        
        offsetsCache.offsets = offsets;
        offsetsCache.version = version || offsetsCache.version;
        offsetsCache.lastUpdate = Date.now();
        
        await saveDatabase();
        
        res.json({
            message: 'Import successful',
            count: offsets.length
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Health check
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        version: offsetsCache.version,
        offsetCount: offsetsCache.offsets.length,
        lastUpdate: new Date(offsetsCache.lastUpdate).toISOString()
    });
});

// Start server
async function start() {
    await initDatabase();
    
    app.listen(PORT, () => {
        console.log(`
╔══════════════════════════════════════════════════════════╗
║         OFFSET MANAGEMENT API SERVER                     ║
╚══════════════════════════════════════════════════════════╝

🚀 Server running on port ${PORT}
📡 API: http://localhost:${PORT}/api
🌐 Dashboard: http://localhost:${PORT}
📊 Offsets loaded: ${offsetsCache.offsets.length}

API Endpoints:
  GET    /api/offsets                 - Get all offsets
  GET    /api/offsets/:name           - Get offset by name
  GET    /api/offsets/category/:cat   - Get by category
  POST   /api/offsets                 - Add new offset
  PUT    /api/offsets/:name           - Update offset
  DELETE /api/offsets/:name           - Delete offset
  POST   /api/offsets/batch           - Batch update
  POST   /api/offsets/reset           - Reset all to 0x0
  GET    /api/export                  - Export JSON
  POST   /api/import                  - Import JSON
  GET    /api/health                  - Health check

Press Ctrl+C to stop
        `);
    });
}

start().catch(console.error);
