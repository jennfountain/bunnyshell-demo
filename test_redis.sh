#!/bin/bash

# Redis API Test Script
# This script tests all Redis endpoints in the FastAPI application

BASE_URL="http://localhost:8000"
echo "Testing FastAPI Redis Integration"
echo "=================================="
echo ""

# Test 1: Health Check
echo "1. Testing Health Check..."
curl -s "$BASE_URL/health" | python3 -m json.tool
echo -e "\n"

# Test 2: Set a cache value
echo "2. Setting cache value (key: test_user, value: John Doe)..."
curl -s -X POST "$BASE_URL/cache/test_user?value=John%20Doe" | python3 -m json.tool
echo -e "\n"

# Test 3: Get the cache value
echo "3. Getting cache value (key: test_user)..."
curl -s "$BASE_URL/cache/test_user" | python3 -m json.tool
echo -e "\n"

# Test 4: Set a cache value with TTL
echo "4. Setting cache value with 60 second TTL (key: temp_data, value: expires_soon)..."
curl -s -X POST "$BASE_URL/cache/temp_data?value=expires_soon&ttl=60" | python3 -m json.tool
echo -e "\n"

# Test 5: List all keys
echo "5. Listing all keys..."
curl -s "$BASE_URL/cache" | python3 -m json.tool
echo -e "\n"

# Test 6: Increment counter
echo "6. Incrementing counter (key: page_views)..."
curl -s -X POST "$BASE_URL/counter/page_views/increment" | python3 -m json.tool
echo -e "\n"

# Test 7: Increment counter by 5
echo "7. Incrementing counter by 5 (key: page_views)..."
curl -s -X POST "$BASE_URL/counter/page_views/increment?amount=5" | python3 -m json.tool
echo -e "\n"

# Test 8: Get counter value
echo "8. Getting counter value (key: page_views)..."
curl -s "$BASE_URL/counter/page_views" | python3 -m json.tool
echo -e "\n"

# Test 9: Decrement counter
echo "9. Decrementing counter by 2 (key: page_views)..."
curl -s -X POST "$BASE_URL/counter/page_views/decrement?amount=2" | python3 -m json.tool
echo -e "\n"

# Test 10: Get counter value again
echo "10. Getting counter value after decrement (key: page_views)..."
curl -s "$BASE_URL/counter/page_views" | python3 -m json.tool
echo -e "\n"

# Test 11: List keys with pattern
echo "11. Listing keys with pattern (pattern: test*)..."
curl -s "$BASE_URL/cache?pattern=test*" | python3 -m json.tool
echo -e "\n"

# Test 12: Delete a key
echo "12. Deleting cache key (key: test_user)..."
curl -s -X DELETE "$BASE_URL/cache/test_user" | python3 -m json.tool
echo -e "\n"

# Test 13: Try to get deleted key (should fail)
echo "13. Trying to get deleted key (key: test_user) - should return 404..."
curl -s "$BASE_URL/cache/test_user" -w "\nHTTP Status: %{http_code}\n"
echo -e "\n"

# Test 14: List all keys again
echo "14. Listing all keys after deletion..."
curl -s "$BASE_URL/cache" | python3 -m json.tool
echo -e "\n"

echo "=================================="
echo "Testing Complete!"
echo "=================================="
