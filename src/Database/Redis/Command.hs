{-# LANGUAGE FlexibleContexts #-}

module Database.Redis.Command where

import Control.Monad.Trans ( MonadIO )
import Control.Failure     ( Failure )
import Database.Redis.Core
import Database.Redis.Internal

-- ---------------------------------------------------------------------------
-- Connection
-- 

-- | Authenticate with a password-protected Redis server. A Redis server can 
-- be configured to require a password before commands can be executed using 
-- the /requirepass/ directive in its configuration file.
auth :: (MonadIO m, Failure RedisError m)
     => Server     -- ^ Redis server connection.
     -> RedisParam -- ^ Password.
     -> m ()       -- ^ Status. "OK" if successful, or an error message 
                   -- otherwise.
auth r pwd = discard $ command r $ multiBulk r "AUTH" [pwd]

-- | Ask a server to silently close a connection.
quit :: (MonadIO m, Failure RedisError m)
     => Server -- ^ Redis server connection.
     -> m () 
quit r = discard $ command r $ multiBulk r "QUIT" []

ping :: (MonadIO m, Failure RedisError m)
     => Server -- ^ Redis server connection.
     -> m RedisValue
ping r = command r $ multiBulk r "PING" []

-- ---------------------------------------------------------------------------
-- Generic
-- 

-- | Test whether a specified RedisKey exists.
exists :: (MonadIO m, Failure RedisError m)
       => Server   -- ^ Redis server connection.
       -> RedisKey -- ^ RedisKey to check.
       -> m Bool
exists r k = boolify $ command r $ multiBulk r "EXISTS" [k] 

del :: (MonadIO m, Failure RedisError m) 
    => Server -> RedisKey -> m RedisValue
del r k = command r $ multiBulk r "DEL" [k]

type' :: (MonadIO m, Failure RedisError m) 
      => Server -> RedisKey -> m RedisValue
type' r k = command r $ multiBulk r "TYPE" [k]

keys :: (MonadIO m, Failure RedisError m) 
     => Server -> RedisParam -> m RedisValue
keys r pattern = command r $ multiBulk r "KEYS" [pattern]

randomkey :: (MonadIO m, Failure RedisError m) 
          => Server -> m RedisValue
randomkey r = command r $ multiBulk r "RANDOMKEY" []

rename :: (MonadIO m, Failure RedisError m) 
       => Server -> RedisKey -> RedisKey -> m RedisValue
rename r old new = command r $ multiBulk r "RENAME" [old, new]

renamex :: (MonadIO m, Failure RedisError m) 
        => Server -> RedisKey -> RedisKey -> m RedisValue
renamex r old new = command r $ multiBulk r "RENAMEX" [old, new]

dbsize :: (MonadIO m, Failure RedisError m) 
       => Server -> m RedisValue
dbsize r = command r $ multiBulk r "DBSIZE" []

expire :: (MonadIO m, Failure RedisError m) 
       => Server -> RedisKey -> Int -> m RedisValue
expire r k secs = command r $ multiBulk r "RENAMEX" [k, toParam secs]

ttl :: (MonadIO m, Failure RedisError m) 
    => Server -> RedisKey -> m RedisValue
ttl r k = command r $ multiBulk r "TTL" [k]

select :: (MonadIO m, Failure RedisError m) 
       => Server -> Int -> m Bool
select r index = boolify $ command r $ multiBulk r "SELECT" [toParam index]

move :: (MonadIO m, Failure RedisError m) 
     => Server -> RedisKey -> Int -> m RedisValue
move r k index = command r $ multiBulk r "MOVE" [k, toParam index]

flushdb :: (MonadIO m, Failure RedisError m) 
        => Server -> m Bool
flushdb r = boolify $ command r $ multiBulk r "FLUSHDB" []

flushall :: (MonadIO m, Failure RedisError m) 
         => Server -> m Bool
flushall r = boolify $ command r $ multiBulk r "FLUSHALL" []

-- ---------------------------------------------------------------------------
-- String
-- 

get :: (MonadIO m, Failure RedisError m) 
    => Server -> RedisKey -> m RedisValue
get r k = command r $ multiBulk r "GET" [k]

set :: (MonadIO m, Failure RedisError m) 
    => Server -> RedisKey -> RedisParam -> m Bool
set r k v = boolify $ command r $ multiBulkT2 r "SET" [(k, v)]

getset :: (MonadIO m, Failure RedisError m) 
       => Server -> RedisKey -> RedisParam -> m RedisValue
getset r k v = command r $ multiBulkT2 r "GETSET" [(k, v)]

mget :: (MonadIO m, Failure RedisError m) 
     => Server -> [RedisKey] -> m RedisValue
mget r ks = command r $ multiBulk r "MGET" ks

setnx :: (MonadIO m, Failure RedisError m) 
      => Server -> RedisKey -> RedisParam -> m Bool
setnx r k v = boolify $ command r $ multiBulkT2 r "SETNX" [(k, v)]

mset :: (MonadIO m, Failure RedisError m) 
     => Server -> [(RedisKey, RedisParam)] -> m ()
mset r kvs = discard $ command r $ multiBulkT2 r "MSET" kvs

msetnx :: (MonadIO m, Failure RedisError m) 
       => Server -> [(RedisKey, RedisParam)] -> m Bool
msetnx r kvs = boolify $ command r $ multiBulkT2 r "MSETNX" kvs

incr :: (MonadIO m, Failure RedisError m) 
     => Server -> RedisKey -> m RedisValue
incr r k = command r $ multiBulk r "INCR" [k]

incrby :: (MonadIO m, Failure RedisError m) 
       => Server -> RedisKey -> Int -> m RedisValue
incrby r k v = command r $ multiBulk r "INCRBY" [k, toParam v]

decr :: (MonadIO m, Failure RedisError m) 
     => Server -> RedisKey -> m RedisValue
decr r k = command r $ multiBulk r "DECR" [k]

decrby :: (MonadIO m, Failure RedisError m) 
       => Server -> RedisKey -> Int -> m RedisValue
decrby r k v = command r $ multiBulk r "DECRBY" [k, toParam v]

-- ---------------------------------------------------------------------------
-- List
-- 

rpush :: (MonadIO m, Failure RedisError m) 
      => Server -> RedisKey -> RedisParam -> m RedisValue
rpush r k v = command r $ multiBulk r "RPUSH" [k, v]

lpush :: (MonadIO m, Failure RedisError m) 
      => Server -> RedisKey -> RedisParam -> m RedisValue
lpush r k v = command r $ multiBulk r "LPUSH" [k, v]

llen :: (MonadIO m, Failure RedisError m) 
     => Server -> RedisKey -> m RedisValue
llen r k = command r $ multiBulk r "LLEN" [k]

lrange :: (MonadIO m, Failure RedisError m) 
       => Server -> RedisKey -> Int -> Int -> m RedisValue
lrange r k start end = command r $ multiBulk r "LRANGE" [k, toParam start, toParam end]

ltrim :: (MonadIO m, Failure RedisError m) 
      => Server -> RedisKey -> Int -> Int -> m RedisValue
ltrim r k start end = command r $ multiBulk r "LTRIM" [k, toParam start, toParam end]

lindex :: (MonadIO m, Failure RedisError m) 
       => Server -> RedisKey -> Int -> m RedisValue
lindex r k index = command r $ multiBulk r "LINDEX" [k, toParam index]

lset :: (MonadIO m, Failure RedisError m) 
     => Server -> RedisKey -> Int -> RedisParam -> m RedisValue
lset r k index value = command r $ multiBulk r "LSET" [k, toParam index, value]

lrem :: (MonadIO m, Failure RedisError m) 
     => Server -> RedisKey -> Int -> RedisParam -> m RedisValue
lrem r k index value = command r $ multiBulk r "LREM" [k, toParam index, value]

lpop :: (MonadIO m, Failure RedisError m) 
     => Server -> RedisKey -> m RedisValue
lpop r k = command r $ multiBulk r "LPOP" [k]

rpop :: (MonadIO m, Failure RedisError m) 
     => Server -> RedisKey -> m RedisValue
rpop r k = command r $ multiBulk r "RPOP" [k]

blpop :: (MonadIO m, Failure RedisError m) 
      => Server -> [RedisKey] -> Int -> m RedisValue
blpop r ks timeout = command r $ multiBulk r "BLPOP" (ks ++ [toParam timeout])

brpop :: (MonadIO m, Failure RedisError m) 
      => Server -> [RedisKey] -> Int -> m RedisValue
brpop r ks timeout = command r $ multiBulk r "BRPOP" (ks ++ [toParam timeout])

rpoplpush :: (MonadIO m, Failure RedisError m) 
          => Server -> RedisKey -> RedisKey -> m RedisValue
rpoplpush r source dest = command r $ multiBulk r "RPOPLPUSH" [source, dest]

-- ---------------------------------------------------------------------------
-- Set
-- 

sadd :: (MonadIO m, Failure RedisError m) 
     => Server -> RedisKey -> RedisParam -> m RedisValue
sadd r k member = command r $ multiBulk r "SADD" [k, member]

srem :: (MonadIO m, Failure RedisError m) 
     => Server -> RedisKey -> RedisParam -> m RedisValue
srem r k member = command r $ multiBulk r "SREM" [k, member]

spop :: (MonadIO m, Failure RedisError m) 
     => Server -> RedisKey -> m RedisValue
spop r k = command r $ multiBulk r "SPOP" [k]

smove :: (MonadIO m, Failure RedisError m) 
      => Server -> RedisKey -> RedisKey -> RedisParam -> m RedisValue
smove r source dest member = command r $ multiBulk r "SMOVE" [source, dest, member]

scard :: (MonadIO m, Failure RedisError m) 
      => Server -> RedisKey -> m RedisValue
scard r k = command r $ multiBulk r "SCARD" [k]

sismember :: (MonadIO m, Failure RedisError m) 
          => Server -> RedisKey -> RedisParam -> m RedisValue
sismember r k member = command r $ multiBulk r "SISMEMBER" [k, member]

sinter :: (MonadIO m, Failure RedisError m) 
       => Server -> [RedisKey] -> m RedisValue
sinter r ks = command r $ multiBulk r "SINTER" ks

sstoreinter :: (MonadIO m, Failure RedisError m) 
            => Server -> RedisKey -> [RedisKey] -> m RedisValue
sstoreinter r dest ks = command r $ multiBulk r "SINTERSTORE" ([dest] ++ ks)

sunion :: (MonadIO m, Failure RedisError m) 
       => Server -> [RedisKey] -> m RedisValue
sunion r ks = command r $ multiBulk r "SUNION" ks

sunionstore :: (MonadIO m, Failure RedisError m) 
            => Server -> RedisKey -> [RedisKey] -> m RedisValue
sunionstore r dest ks = command r $ multiBulk r "SUNIONSTORE" ([dest] ++ ks)

sdiff :: (MonadIO m, Failure RedisError m) 
      => Server -> [RedisKey] -> m RedisValue
sdiff r ks = command r $ multiBulk r "SDIFF" ks

sdiffstore :: (MonadIO m, Failure RedisError m) 
           => Server -> RedisKey -> [RedisKey] -> m RedisValue
sdiffstore r dest ks = command r $ multiBulk r "SDIFFSTORE" ([dest] ++ ks)

smembers :: (MonadIO m, Failure RedisError m) 
         => Server -> RedisKey -> m RedisValue
smembers r k = command r $ multiBulk r "SMEMBERS" [k]

srandmember :: (MonadIO m, Failure RedisError m) 
            => Server -> RedisKey -> m RedisValue
srandmember r k = command r $ multiBulk r "SRANDMEMBER" [k]

-- ---------------------------------------------------------------------------
-- Zset
-- 

{-
zadd k score member = command r $ multiBulk r "ZADD" [
zremove k member = "ZREM"
zIncrementBy k = "ZINCRBY"
zrange k start end = "ZRANGE"
reverseRange k start end = "ZREVRANGE"
rangeByScore k min max = "ZRANGEBYSCORE"
zcardinality k = "ZCARD"
score k element = "ZSCORE"
removeRangeByScore k min max = "ZREMRANGEBYSCORE"
-}

-- ---------------------------------------------------------------------------
-- Hashes
-- 
-- TBD


-- ---------------------------------------------------------------------------
-- Sort
-- 

data Direction = ASC | DESC deriving (Show)

data Sorting = Sorting { sortBy :: Maybe RedisParam
                       , sortLimit :: Maybe (Int, Int)
                       , sortGet :: Maybe RedisParam
                       , sortDirection :: Maybe Direction
                       , sortAlpha :: Maybe Bool
                       , sortStore :: Maybe RedisParam } deriving (Show)

defaultSorting :: Sorting
defaultSorting = Sorting { sortBy = Nothing
                         , sortLimit = Nothing
                         , sortGet = Nothing
                         , sortDirection = Nothing
                         , sortAlpha = Just False
                         , sortStore = Nothing }

sort :: (MonadIO m, Failure RedisError m) 
     => Server -> RedisKey -> Sorting -> m RedisValue
sort r k sorting =
    command r $ multiBulk r "SORT" ([k] ++
        (case (sortBy sorting) of
            Nothing -> [] 
            Just val -> ["BY", val]) ++
        (case (sortLimit sorting) of
            Nothing -> []
            Just (start, end) -> ["LIMIT", toParam start, toParam end]) ++
        (case (sortGet sorting) of
            Nothing -> []
            Just val -> ["GET", val]) ++ 
        (case (sortDirection sorting) of
            Nothing -> []
            Just ASC -> ["ASC"]
            Just DESC -> ["DESC"]) ++
        (case (sortAlpha sorting) of
            Nothing -> []
            Just True -> ["ALPHA"]
            Just False -> []) ++
        (case (sortStore sorting) of
            Nothing -> []
            Just val -> ["STORE", val]))

-- ---------------------------------------------------------------------------
-- Persistence
-- 

save :: (MonadIO m, Failure RedisError m) 
     => Server -> m RedisValue
save r = command r $ multiBulk r "SAVE" []

bgsave :: (MonadIO m, Failure RedisError m) 
       => Server -> m RedisValue
bgsave r = command r $ multiBulk r "BGSAVE" []

lastsave :: (MonadIO m, Failure RedisError m) 
         => Server -> m RedisValue
lastsave r = command r $ multiBulk r "LASTSAVE" []

shutdown :: (MonadIO m, Failure RedisError m) 
         => Server -> m RedisValue
shutdown r = command r $ multiBulk r "SHUTDOWN" []

bgrewriteaof :: (MonadIO m, Failure RedisError m) 
             => Server -> m RedisValue
bgrewriteaof r = command r $ multiBulk r "BGREWRITEAOF" []


-- ---------------------------------------------------------------------------
-- PUBLISH
-- 
publish :: (MonadIO m, Failure RedisError m) 
     => Server -> RedisKey -> RedisParam -> m RedisValue
publish r channel pubvalue = command r $ multiBulk r "PUBLISH" [channel, pubvalue]



-- ---------------------------------------------------------------------------
-- Remote Server
-- 

info :: (MonadIO m, Failure RedisError m) 
     => Server -> m RedisValue
info r = command r $ multiBulk r "INFO" []

monitor :: (MonadIO m, Failure RedisError m) 
        => Server -> m RedisValue
monitor r = command r $ multiBulk r "MONITOR" []

-- FIXME this is not the slaveof command!
{-slaveof :: (MonadIO m, Failure RedisError m) -}
{-        => Server -> RedisParam -> RedisParam -> m RedisValue-}
{-slaveof r host port = command r $ multiBulk r "SAVE" [host, port]-}

