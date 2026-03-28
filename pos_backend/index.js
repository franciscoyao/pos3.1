const express = require('express');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const db = require('./db');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// ─── Socket.io Setup ───────────────────────────────────────────
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST', 'PUT', 'DELETE'] },
  pingInterval: 10000,
  pingTimeout: 5000,
});

io.on('connection', (socket) => {
  console.log(`Client connected: ${socket.id}`);
  socket.on('disconnect', () => console.log(`Client disconnected: ${socket.id}`));
});

// Helper: broadcast event to all connected clients
function broadcast(event, data) {
  io.emit(event, data);
}

// ─── Categories ────────────────────────────────────────────────
app.get('/api/categories', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT * FROM categories ORDER BY sort_order ASC, id ASC');
    res.json(rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post('/api/categories', async (req, res) => {
  try {
    const { name, sort_order, station, order_type } = req.body;
    const result = await db.query(
      'INSERT INTO categories (name, sort_order, station, order_type) VALUES ($1, $2, $3, $4) RETURNING *',
      [name, sort_order || 0, station || null, order_type || 'Both']
    );
    res.status(201).json(result.rows[0]);
    broadcast('product_updated');
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.put('/api/categories/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, sort_order, station, order_type } = req.body;
    const result = await db.query(
      'UPDATE categories SET name=$1, sort_order=$2, station=$3, order_type=$4 WHERE id=$5 RETURNING *',
      [name, sort_order || 0, station || null, order_type || 'Both', id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Category not found' });
    res.json(result.rows[0]);
    broadcast('product_updated');
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.delete('/api/categories/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const checkProducts = await db.query('SELECT id FROM products WHERE category_id=$1', [id]);
    if (checkProducts.rows.length > 0) {
      return res.status(400).json({ error: 'Cannot delete category because it contains menu items.' });
    }
    const check = await db.query('SELECT id FROM categories WHERE id=$1', [id]);
    if (check.rows.length === 0) return res.status(404).json({ error: 'Category not found' });
    await db.query('DELETE FROM categories WHERE id=$1', [id]);
    res.status(204).send();
    broadcast('product_updated');
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ─── Subcategories ─────────────────────────────────────────────
app.get('/api/subcategories', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT * FROM subcategories ORDER BY sort_order ASC, id ASC');
    res.json(rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post('/api/subcategories', async (req, res) => {
  try {
    const { category_id, name, sort_order } = req.body;
    const result = await db.query(
      'INSERT INTO subcategories (category_id, name, sort_order) VALUES ($1, $2, $3) RETURNING *',
      [category_id, name, sort_order || 0]
    );
    res.status(201).json(result.rows[0]);
    broadcast('product_updated');
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.put('/api/subcategories/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { category_id, name, sort_order } = req.body;
    const result = await db.query(
      'UPDATE subcategories SET category_id=$1, name=$2, sort_order=$3 WHERE id=$4 RETURNING *',
      [category_id, name, sort_order || 0, id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Subcategory not found' });
    res.json(result.rows[0]);
    broadcast('product_updated');
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.delete('/api/subcategories/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const check = await db.query('SELECT id FROM subcategories WHERE id=$1', [id]);
    if (check.rows.length === 0) return res.status(404).json({ error: 'Subcategory not found' });
    await db.query('DELETE FROM subcategories WHERE id=$1', [id]);
    res.status(204).send();
    broadcast('product_updated');
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ─── Products ──────────────────────────────────────────────────
app.get('/api/products', async (req, res) => {
  try {
    const { rows: products } = await db.query('SELECT * FROM products WHERE is_deleted = FALSE OR is_deleted IS NULL ORDER BY id ASC');
    const { rows: extras } = await db.query('SELECT * FROM product_extras');
    
    // Attach extras to products
    const extrasByProduct = {};
    for (const extra of extras) {
      if (!extrasByProduct[extra.product_id]) extrasByProduct[extra.product_id] = [];
      extrasByProduct[extra.product_id].push(extra);
    }
    for (const p of products) {
      p.extras = extrasByProduct[p.id] || [];
    }
    
    res.json(products);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/products/popular', async (req, res) => {
  try {
    const { orderType } = req.query;
    
    const query = `
      SELECT p.*, SUM(oi.quantity) as total_qty
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      WHERE (p.is_deleted = FALSE OR p.is_deleted IS NULL)
      AND ($1::text IS NULL OR o.order_type = $1)
      GROUP BY p.id
      ORDER BY total_qty DESC
      LIMIT 10
    `;
    let { rows } = await db.query(query, [orderType || null]);
    
    if (rows.length === 0) {
      const fallbackQuery = `
        SELECT p.*
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE (p.is_deleted = FALSE OR p.is_deleted IS NULL)
        AND ($1::text IS NULL OR c.order_type = 'Both' OR c.order_type = $1)
        LIMIT 10
      `;
      const fallback = await db.query(fallbackQuery, [orderType || null]);
      rows = fallback.rows;
    }
    
    if (rows.length > 0) {
      const productIds = rows.map(r => r.id);
      const { rows: extras } = await db.query('SELECT * FROM product_extras WHERE product_id = ANY($1::int[])', [productIds]);
      const extrasByProduct = {};
      for (const extra of extras) {
        if (!extrasByProduct[extra.product_id]) extrasByProduct[extra.product_id] = [];
        extrasByProduct[extra.product_id].push(extra);
      }
      for (const p of rows) p.extras = extrasByProduct[p.id] || [];
    }
    res.json(rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post('/api/products', async (req, res) => {
  try {
    const { item_code, name, price, category_id, subcategory_id, station, type, is_available, allow_price_edit } = req.body;
    const result = await db.query(
      `INSERT INTO products (item_code, name, price, category_id, subcategory_id, station, type, is_available, allow_price_edit) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
      [item_code, name, price, category_id, subcategory_id || null, station, type, is_available ?? true, allow_price_edit ?? false]
    );
    res.status(201).json(result.rows[0]);
    broadcast('product_updated');
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.put('/api/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { item_code, name, price, category_id, subcategory_id, station, type, is_available, allow_price_edit } = req.body;
    const result = await db.query(
      `UPDATE products 
       SET item_code=$1, name=$2, price=$3, category_id=$4, subcategory_id=$5, station=$6, type=$7, is_available=$8, allow_price_edit=$9 
       WHERE id=$10 RETURNING *`,
      [item_code, name, price, category_id, subcategory_id || null, station, type, is_available ?? true, allow_price_edit ?? false, id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Product not found' });
    res.json(result.rows[0]);
    broadcast('product_updated');
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.delete('/api/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const check = await db.query('SELECT id FROM products WHERE id=$1', [id]);
    if (check.rows.length === 0) return res.status(404).json({ error: 'Product not found' });
    
    // Check if product is used in order_items
    const checkOrders = await db.query('SELECT id FROM order_items WHERE product_id=$1 LIMIT 1', [id]);
    if (checkOrders.rows.length > 0) {
      // Soft delete if ordered
      await db.query('UPDATE products SET is_deleted=TRUE WHERE id=$1', [id]);
    } else {
      // Hard delete if never ordered
      await db.query('DELETE FROM product_extras WHERE product_id=$1', [id]);
      await db.query('DELETE FROM products WHERE id=$1', [id]);
    }
    
    res.status(204).send();
    broadcast('product_updated');
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post('/api/products/:id/extras', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, price } = req.body;
    const result = await db.query(
      'INSERT INTO product_extras (product_id, name, price) VALUES ($1, $2, $3) RETURNING *',
      [id, name, price || 0]
    );
    res.status(201).json(result.rows[0]);
    broadcast('product_updated');
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.delete('/api/products/extras/:extraId', async (req, res) => {
  try {
    const { extraId } = req.params;
    await db.query('DELETE FROM product_extras WHERE id=$1', [extraId]);
    res.status(204).send();
    broadcast('product_updated');
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ─── Tables ────────────────────────────────────────────────────
app.get('/api/tables', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT * FROM tables ORDER BY table_number ASC');
    res.json(rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post('/api/tables', async (req, res) => {
  try {
    const { table_number, status, guest_count } = req.body;
    const result = await db.query(
      'INSERT INTO tables (table_number, status, guest_count) VALUES ($1, $2, $3) RETURNING *',
      [table_number, status || 'Available', guest_count || 0]
    );
    res.status(201).json(result.rows[0]);
    broadcast('table_updated');
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.put('/api/tables/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { status, order_code, guest_count } = req.body;
    const result = await db.query(
      `UPDATE tables SET status=$1, order_code=$2, guest_count=$3, updated_at=NOW() WHERE id=$4 RETURNING *`,
      [status, order_code, guest_count, id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Table not found' });
    res.json(result.rows[0]);
    broadcast('table_updated');
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ─── Orders ────────────────────────────────────────────────────
app.get('/api/orders', async (req, res) => {
  try {
    const includeItems = req.query.include_items === 'true';
    const statusFilter = req.query.status; // optional: ?status=Pending,In+Progress
    const stationFilter = req.query.station; // optional: ?station=Kitchen

    let orderQuery = 'SELECT * FROM orders';
    const params = [];
    if (statusFilter) {
      const statuses = statusFilter.split(',').map(s => s.trim());
      const placeholders = statuses.map((_, i) => `$${i + 1}`).join(',');
      orderQuery += ` WHERE status IN (${placeholders})`;
      params.push(...statuses);
    }
    orderQuery += ' ORDER BY created_at DESC';

    let { rows: orders } = await db.query(orderQuery, params);

    if (includeItems && orders.length > 0) {
      const orderIds = orders.map(o => o.id);
      const placeholders = orderIds.map((_, i) => `$${i + 1}`).join(',');
      
      let itemsQuery = `
         SELECT oi.order_id, oi.id, oi.quantity, oi.price, oi.notes, oi.extras, p.name, p.station
         FROM order_items oi JOIN products p ON oi.product_id = p.id
         WHERE oi.order_id IN (${placeholders})
      `;
      let itemsParams = [...orderIds];
      
      if (stationFilter) {
        itemsQuery += ` AND p.station = $${itemsParams.length + 1}`;
        itemsParams.push(stationFilter);
      }

      const { rows: items } = await db.query(itemsQuery, itemsParams);
      
      // Group items by order_id
      const itemsByOrder = {};
      for (const item of items) {
        if (!itemsByOrder[item.order_id]) itemsByOrder[item.order_id] = [];
        itemsByOrder[item.order_id].push(item);
      }
      
      if (stationFilter) {
        orders = orders.filter(o => {
          o.items = itemsByOrder[o.id] || [];
          return o.items.length > 0;
        });
      } else {
        for (const order of orders) {
          order.items = itemsByOrder[order.id] || [];
        }
      }
    }

    res.json(orders);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/orders/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const orderRes = await db.query('SELECT * FROM orders WHERE id=$1', [id]);
    if (orderRes.rows.length === 0) return res.status(404).json({ error: 'Order not found' });
    const order = orderRes.rows[0];
    const itemsRes = await db.query(
      `SELECT oi.id, oi.quantity, oi.price, oi.notes, oi.extras, p.name, p.station
       FROM order_items oi JOIN products p ON oi.product_id = p.id 
       WHERE oi.order_id = $1`, [id]
    );
    order.items = itemsRes.rows;
    res.json(order);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post('/api/orders', async (req, res) => {
  const client = await db.getClient();
  try {
    const { total, items, order_type, table_no, order_code, waiter_name } = req.body;
    
    await client.query('BEGIN');
    
    // Check if dine-in table is already occupied
    if (order_type === 'Dine-In' && table_no) {
      const tbCheck = await client.query('SELECT status FROM tables WHERE table_number=$1 FOR UPDATE', [table_no]);
      if (tbCheck.rows.length > 0 && tbCheck.rows[0].status === 'Occupied') {
        await client.query('ROLLBACK');
        client.release();
        return res.status(409).json({ error: 'Table is already occupied by another order.' });
      }
    }
    
    const orderResult = await client.query(
      'INSERT INTO orders (total, order_type, table_no, order_code, waiter_name, status) VALUES ($1,$2,$3,$4,$5,$6) RETURNING id',
      [total, order_type, table_no, order_code, waiter_name, 'Pending']
    );
    const orderId = orderResult.rows[0].id;
    
    for (let item of items) {
      await client.query(
        'INSERT INTO order_items (order_id, product_id, quantity, price, notes, extras) VALUES ($1,$2,$3,$4,$5,$6)',
        [orderId, item.product_id, item.quantity, item.price, item.notes, JSON.stringify(item.extras || [])]
      );
    }
    
    // If dine-in, mark the table as Occupied
    if (order_type === 'Dine-In' && table_no) {
      await client.query(
        `UPDATE tables SET status='Occupied', order_code=$1, updated_at=NOW() WHERE table_number=$2`,
        [order_code, table_no]
      );
    }
    
    await client.query('COMMIT');
    res.status(201).json({ id: orderId, order_code, message: 'Order created' });
    broadcast('order_created');
    broadcast('table_updated');
  } catch (err) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

app.put('/api/orders/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const result = await db.query(
      'UPDATE orders SET status=$1, updated_at=NOW() WHERE id=$2 RETURNING *',
      [status, id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Order not found' });
    res.json(result.rows[0]);
    broadcast('order_updated');
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ─── Merge & Split ──────────────────────────────────────────────
app.post('/api/orders/merge', async (req, res) => {
  const { targetOrderId, sourceOrderId } = req.body;
  if (!targetOrderId || !sourceOrderId) return res.status(400).json({ error: 'Missing targetId or sourceId' });
  
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    
    // Lock both orders to prevent race conditions (lock target then source or sort them to prevent deadlocks)
    // To be simple, we lock source first
    const sourceRes = await client.query('SELECT * FROM orders WHERE id = $1 FOR UPDATE', [sourceOrderId]);
    if (sourceRes.rows.length === 0) throw new Error("Source order not found");
    const source = sourceRes.rows[0];

    const targetRes = await client.query('SELECT * FROM orders WHERE id = $1 FOR UPDATE', [targetOrderId]);
    if (targetRes.rows.length === 0) throw new Error("Target order not found");
    
    // Move all items
    await client.query('UPDATE order_items SET order_id = $1 WHERE order_id = $2', [targetOrderId, sourceOrderId]);
    
    // Add totals to target
    await client.query(`
      UPDATE orders 
      SET 
        subtotal = subtotal + $1,
        tax_amount = tax_amount + $2,
        service_amount = service_amount + $3,
        tip_amount = tip_amount + $4,
        total = total + $5
      WHERE id = $6
    `, [source.subtotal, source.tax_amount, source.service_amount, source.tip_amount, source.total, targetOrderId]);
    
    // Delete source order
    await client.query('DELETE FROM orders WHERE id = $1', [sourceOrderId]);
    
    await client.query('COMMIT');
    res.json({ success: true });
    broadcast('order_updated');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  } finally {
    client.release();
  }
});

app.post('/api/orders/:id/split', async (req, res) => {
  const sourceOrderId = parseInt(req.params.id);
  const { 
    splitItems, // array of { id: orderItemId, quantityToMove }
    newTableNo, 
    newOrderType,
    sourceNewSubtotal, sourceNewTax, sourceNewService, sourceNewTotal,
    targetSubtotal, targetTax, targetService, targetTotal
  } = req.body;
  
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    
    // 1. Create new order
    const orderCode = `ORD-${Date.now().toString().slice(-6)}`;
    const newOrderRes = await client.query(
      'INSERT INTO orders (order_code, type, table_no, status, subtotal, tax_amount, service_amount, tip_amount, total) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *',
      [orderCode, newOrderType, newTableNo, 'In Progress', targetSubtotal, targetTax, targetService, 0, targetTotal]
    );
    const newOrderId = newOrderRes.rows[0].id;
    
    // 2. Loop through split items
    for (const item of splitItems) {
      if (item.quantityToMove <= 0) continue;
      
      const itemRes = await client.query('SELECT * FROM order_items WHERE id = $1 AND order_id = $2', [item.id, sourceOrderId]);
      if (itemRes.rows.length === 0) continue;
      const existingItem = itemRes.rows[0];
      
      if (existingItem.quantity === item.quantityToMove) {
        // Move the whole row
        await client.query('UPDATE order_items SET order_id = $1 WHERE id = $2', [newOrderId, item.id]);
      } else {
        // Move partial
        const remainingQty = existingItem.quantity - item.quantityToMove;
        const newOldTotalPrice = remainingQty * existingItem.price;
        const targetItemTotalPrice = item.quantityToMove * existingItem.price;
        
        await client.query('UPDATE order_items SET quantity = $1, total_price = $2 WHERE id = $3', [remainingQty, newOldTotalPrice, item.id]);
        await client.query(
          'INSERT INTO order_items (order_id, product_id, quantity, price, total_price, extras) VALUES ($1, $2, $3, $4, $5, $6)',
          [newOrderId, existingItem.product_id, item.quantityToMove, existingItem.price, targetItemTotalPrice, existingItem.extras]
        );
      }
    }
    
    // 3. Update source order totals
    await client.query(`
      UPDATE orders 
      SET subtotal = $1, tax_amount = $2, service_amount = $3, total = $4
      WHERE id = $5
    `, [sourceNewSubtotal, sourceNewTax, sourceNewService, sourceNewTotal, sourceOrderId]);
    
    await client.query('COMMIT');
    res.json({ success: true, newOrderId });
    broadcast('order_updated');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: 'Internal Server Error' });
  } finally {
    client.release();
  }
});

// ─── Checkout ──────────────────────────────────────────────────
app.post('/api/checkout', async (req, res) => {
  const client = await db.getClient();
  try {
    const { order_id, payment_method, waiter_name, subtotal, tax_amount, service_amount, tip_amount, total } = req.body;
    
    await client.query('BEGIN');
    
    // Fetch order to get details and LOCK row
    const orderRes = await client.query('SELECT * FROM orders WHERE id=$1 FOR UPDATE', [order_id]);
    if (orderRes.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Order not found' });
    }
    const order = orderRes.rows[0];

    // Prevent double checkouts
    if (order.status === 'Completed' || order.bill_id != null) {
      await client.query('ROLLBACK');
      return res.status(409).json({ error: 'Order is already checked out.' });
    }

    // Generate bill number
    const billNum = `BILL-${Date.now()}`;

    // Create bill
    const billResult = await client.query(
      `INSERT INTO bills (bill_number, order_type, table_no, waiter_name, payment_method, subtotal, tax_amount, service_amount, tip_amount, total)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING *`,
      [billNum, order.order_type, order.table_no, waiter_name || order.waiter_name, payment_method,
       subtotal || order.total, tax_amount || 0, service_amount || 0, tip_amount || 0, total || order.total]
    );
    const bill = billResult.rows[0];

    // Link order to bill and mark Completed
    await client.query('UPDATE orders SET bill_id=$1, status=$2 WHERE id=$3', [bill.id, 'Completed', order_id]);

    // Free up the table
    if (order.table_no) {
      await client.query(
        `UPDATE tables SET status='Available', order_code=NULL, updated_at=NOW() WHERE table_number=$1`,
        [order.table_no]
      );
    }
    
    await client.query('COMMIT');
    res.status(201).json(bill);
    broadcast('checkout_completed');
    broadcast('table_updated');
    broadcast('order_updated');
  } catch (err) { 
    await client.query('ROLLBACK');
    res.status(500).json({ error: err.message }); 
  } finally {
    client.release();
  }
});

// ─── Bills ────────────────────────────────────────────────────
app.get('/api/bills', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT * FROM bills ORDER BY created_at DESC');
    res.json(rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/bills/:id/details', async (req, res) => {
  try {
    const { id } = req.params;
    const billRes = await db.query('SELECT * FROM bills WHERE id=$1', [id]);
    if (billRes.rows.length === 0) return res.status(404).json({ error: 'Bill not found' });
    const bill = billRes.rows[0];
    const itemsRes = await db.query(
      `SELECT oi.quantity, oi.price, oi.notes, oi.extras, p.name, p.station
       FROM order_items oi
       JOIN orders o ON oi.order_id = o.id
       JOIN products p ON oi.product_id = p.id
       WHERE o.bill_id = $1`, [id]
    );
    bill.items = itemsRes.rows;
    res.json(bill);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ─── Users ────────────────────────────────────────────────────
app.get('/api/users', async (req, res) => {
  try {
    const { rows } = await db.query('SELECT * FROM users ORDER BY id ASC');
    res.json(rows);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post('/api/users', async (req, res) => {
  try {
    const { full_name, username, pin, role, status } = req.body;
    const result = await db.query(
      `INSERT INTO users (full_name, username, pin, role, status) VALUES ($1,$2,$3,$4,$5) RETURNING *`,
      [full_name, username, pin, role, status || 'Active']
    );
    res.status(201).json(result.rows[0]);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.put('/api/users/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { full_name, username, pin, role, status } = req.body;
    const result = await db.query(
      `UPDATE users SET full_name=$1, username=$2, pin=$3, role=$4, status=$5 WHERE id=$6 RETURNING *`,
      [full_name, username, pin, role, status || 'Active', id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'User not found' });
    res.json(result.rows[0]);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.delete('/api/users/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const check = await db.query('SELECT is_default FROM users WHERE id=$1', [id]);
    if (check.rows.length === 0) return res.status(404).json({ error: 'User not found' });
    if (check.rows[0].is_default) return res.status(403).json({ error: 'Cannot delete default users' });
    await db.query('DELETE FROM users WHERE id=$1', [id]);
    res.status(204).send();
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ─── Login ────────────────────────────────────────────────────
app.post('/api/login', async (req, res) => {
  try {
    const { username, pin, role } = req.body;
    let query, params;
    if (role === 'Admin' || role === 'Waiter') {
      if (!username || !pin) return res.status(400).json({ error: 'Username and PIN required' });
      query = 'SELECT * FROM users WHERE username=$1 AND pin=$2 AND role=$3';
      params = [username, pin, role];
    } else {
      query = 'SELECT * FROM users WHERE role=$1 LIMIT 1';
      params = [role];
    }
    const { rows } = await db.query(query, params);
    if (rows.length > 0) {
      res.json({ success: true, user: rows[0] });
    } else {
      res.status(401).json({ error: 'Invalid credentials' });
    }
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ─── Reports ──────────────────────────────────────────────────
app.get('/api/reports/summary', async (req, res) => {
  try {
    // Overall stats from bills
    const statsRes = await db.query(`
      SELECT
        COALESCE(SUM(total), 0)  AS total_revenue,
        COUNT(*)                  AS total_orders,
        COALESCE(AVG(total), 0)  AS avg_order_value
      FROM bills
    `);
    const stats = statsRes.rows[0];

    // Sales by day — last 7 days
    const salesByDayRes = await db.query(`
      SELECT
        TO_CHAR(created_at::date, 'YYYY-MM-DD') AS day,
        COALESCE(SUM(total), 0)                 AS revenue,
        COUNT(*)                                 AS orders
      FROM bills
      WHERE created_at >= NOW() - INTERVAL '7 days'
      GROUP BY created_at::date
      ORDER BY created_at::date ASC
    `);

    // Sales by category
    const salesByCategoryRes = await db.query(`
      SELECT
        COALESCE(c.name, 'Uncategorized')        AS category,
        COALESCE(SUM(oi.price * oi.quantity), 0) AS revenue
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      LEFT JOIN categories c ON p.category_id = c.id
      GROUP BY c.name
      ORDER BY revenue DESC
    `);

    // Top 5 selling products
    const topItemsRes = await db.query(`
      SELECT
        p.name,
        SUM(oi.quantity)              AS total_qty,
        SUM(oi.price * oi.quantity)   AS total_revenue
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      GROUP BY p.name
      ORDER BY total_qty DESC
      LIMIT 5
    `);

    res.json({
      total_revenue:    parseFloat(stats.total_revenue),
      total_orders:     parseInt(stats.total_orders),
      avg_order_value:  parseFloat(stats.avg_order_value),
      sales_by_day: salesByDayRes.rows.map(r => ({
        day:     r.day,
        revenue: parseFloat(r.revenue),
        orders:  parseInt(r.orders),
      })),
      sales_by_category: salesByCategoryRes.rows.map(r => ({
        category: r.category,
        revenue:  parseFloat(r.revenue),
      })),
      top_items: topItemsRes.rows.map(r => ({
        name:          r.name,
        total_qty:     parseInt(r.total_qty),
        total_revenue: parseFloat(r.total_revenue),
      })),
    });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => { console.log(`Server running on port ${PORT} (HTTP + WebSocket)`); });
