const kCacheLocalStorage = 'localStorage';
const kCacheMemoryStorage = 'memoryStorage';
const kCacheSessionStorage = 'sessionStorage';

enum CacheLocation {
  localStorage(kCacheLocalStorage),
  memoryStorage(kCacheMemoryStorage),
  sessionStorage(kCacheSessionStorage);

  final String value;

  const CacheLocation(this.value);
}
