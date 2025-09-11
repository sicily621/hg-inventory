// src/test/setup.ts
// Mock MutationObserver
class MockMutationObserver {
  constructor(callback: MutationCallback) {}
  observe() {}
  disconnect() {}
  takeRecords(): MutationRecord[] {
    return [];
  }
}

// Mock ResizeObserver
class MockResizeObserver {
  constructor(callback: ResizeObserverCallback) {}
  observe() {}
  unobserve() {}
  disconnect() {}
}

// 全局注入
global.MutationObserver = MockMutationObserver;
global.ResizeObserver = MockResizeObserver;

// 可选：mock requestAnimationFrame，避免 warning
window.requestAnimationFrame = (cb) => setTimeout(cb, 0);
window.cancelAnimationFrame = (id) => clearTimeout(id);
