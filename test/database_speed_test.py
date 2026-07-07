import time
import psycopg

def pgsql_test():
    host = 'localhost'
    port = '5432'
    user = 'root'
    passwd = 'root'
    database = 'main'
    
    print("Connecting to the database...")
    try:
        conn = psycopg.connect(
            host=host,
            port=port,
            user=user,
            password=passwd,
            dbname=database
        )
        print("Connected successfully!")
    except Exception as e:
        print(f"Failed to connect to the database: {e}")
        return

    table_name = "speed_test_table"
    
    try:
        with conn.cursor() as cur:
            # Drop table if exists
            cur.execute(f"DROP TABLE IF EXISTS {table_name};")
            # Create table
            cur.execute(f"CREATE TABLE {table_name} (id SERIAL PRIMARY KEY, data TEXT);")
            conn.commit()
            
        print("\n--- Starting Write Speed Test ---")
        
        # Test 1: Write Speed (Individual Transactions)
        print("1. Testing write speed (individual commits / autocommit)...")
        conn.autocommit = True
        start_time = time.time()
        write_count = 0
        duration = 3.0  # seconds
        
        while time.time() - start_time < duration:
            with conn.cursor() as cur:
                cur.execute(f"INSERT INTO {table_name} (data) VALUES (%s);", (f"data_{write_count}",))
            write_count += 1
            
        elapsed_write = time.time() - start_time
        writes_per_sec = write_count / elapsed_write
        print(f"   Completed {write_count} writes in {elapsed_write:.2f} seconds.")
        print(f"   Write Speed (sequential commits): {writes_per_sec:.2f} writes/sec")

        # Test 2: Write Speed (Single Transaction / Batched)
        print("\n2. Testing write speed (single transaction / batch)...")
        conn.autocommit = False
        batch_size = 10000
        start_time = time.time()
        
        with conn.cursor() as cur:
            for i in range(batch_size):
                cur.execute(f"INSERT INTO {table_name} (data) VALUES (%s);", (f"batch_{i}",))
            conn.commit()
            
        elapsed_batch = time.time() - start_time
        batch_writes_per_sec = batch_size / elapsed_batch
        print(f"   Completed {batch_size} writes in {elapsed_batch:.2f} seconds.")
        print(f"   Write Speed (batch transaction): {batch_writes_per_sec:.2f} writes/sec")

        # Turn autocommit back on so SELECTs and subsequent tests don't leave connection in INTRANS state
        conn.autocommit = True

        # Fetch count for read test
        with conn.cursor() as cur:
            cur.execute(f"SELECT COUNT(*) FROM {table_name};")
            total_rows = cur.fetchone()[0]
            print(f"\nTotal rows in database for read testing: {total_rows}")

        print("\n--- Starting Read Speed Test ---")
        
        # Test 3: Read Speed (Sequential Single-Row Selects)
        print("3. Testing read speed (sequential single-row lookups)...")
        read_count = 0
        start_time = time.time()
        
        while time.time() - start_time < duration:
            target_id = (read_count % total_rows) + 1
            with conn.cursor() as cur:
                cur.execute(f"SELECT data FROM {table_name} WHERE id = %s;", (target_id,))
                cur.fetchone()
            read_count += 1
            
        elapsed_read = time.time() - start_time
        reads_per_sec = read_count / elapsed_read
        print(f"   Completed {read_count} reads in {elapsed_read:.2f} seconds.")
        print(f"   Read Speed (sequential lookups): {reads_per_sec:.2f} reads/sec")

        # Test 4: Read Speed (Bulk Selects)
        print("\n4. Testing read speed (bulk fetch)...")
        start_time = time.time()
        bulk_fetches = 0
        bulk_rows_total = 0
        
        while time.time() - start_time < duration:
            with conn.cursor() as cur:
                cur.execute(f"SELECT * FROM {table_name} LIMIT 1000;")
                rows = cur.fetchall()
                bulk_rows_total += len(rows)
            bulk_fetches += 1
            
        elapsed_bulk = time.time() - start_time
        bulk_fetches_per_sec = bulk_fetches / elapsed_bulk
        bulk_rows_per_sec = bulk_rows_total / elapsed_bulk
        print(f"   Completed {bulk_fetches} bulk queries (fetched {bulk_rows_total} rows) in {elapsed_bulk:.2f} seconds.")
        print(f"   Query Speed: {bulk_fetches_per_sec:.2f} queries/sec")
        print(f"   Row Fetch Speed: {bulk_rows_per_sec:.2f} rows/sec")

    except Exception as e:
        print(f"\nAn error occurred during testing: {e}")
        
    finally:
        # Cleanup
        print("\nCleaning up database...")
        try:
            # If connection is open and active, ensure autocommit is on and drop table
            if conn and not conn.closed:
                # If transaction is in progress, roll it back to allow cleanup
                if conn.info.transaction_status == psycopg.pq.TransactionStatus.INTRANS:
                    conn.rollback()
                conn.autocommit = True
                with conn.cursor() as cur:
                    cur.execute(f"DROP TABLE IF EXISTS {table_name};")
                print("Cleanup successful.")
        except Exception as e:
            print(f"Failed to cleanup table: {e}")
            
        if conn and not conn.closed:
            conn.close()
            print("Connection closed.")

if __name__ == '__main__':
    pgsql_test()