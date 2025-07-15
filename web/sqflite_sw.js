// From https://github.com/tekartik/sqflite/tree/master/packages_web/sqflite_common_ffi_web
importScripts('https://unpkg.com/sql.js@1.6.2/dist/sql-wasm.js');

class SQLiteDBWeb {
  constructor() {
    this.db = null;
  }

  async init() {
    const sqlPromise = initSqlJs({
      locateFile: file => `https://unpkg.com/sql.js@1.6.2/dist/${file}`
    });
    const SQL = await sqlPromise;
    this.db = new SQL.Database();
  }

  execute(sql, params = []) {
    return this.db.exec(sql, params);
  }

  prepare(sql) {
    return this.db.prepare(sql);
  }

  close() {
    this.db.close();
  }
}

self.addEventListener('message', async (event) => {
  const { id, method, params } = event.data;
  
  try {
    let result;
    switch (method) {
      case 'init':
        result = await new SQLiteDBWeb().init();
        break;
      default:
        throw new Error(`Unknown method: ${method}`);
    }
    
    self.postMessage({ id, result });
  } catch (error) {
    self.postMessage({ id, error: error.message });
  }
});