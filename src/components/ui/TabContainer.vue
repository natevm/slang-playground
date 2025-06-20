<script setup lang="ts">
import { ref, provide } from 'vue'
import { tabInjectKey } from './TabInterface'

type TabData = {
  name: string
  label: string
}

// Active tab state
const activeTab = ref('')

// Registered tabs store
const tabs = ref<TabData[]>([])

// Drag-and-drop reordering state
const draggingIndex = ref<number | null>(null)
// Current drag-over index to show drop indicator
const dragOverIndex = ref<number | null>(null)

// Event emitter for the "add-tab" action
const emit = defineEmits<{ (event: 'add-tab'): void }>()

// Register a new tab
function registerTab(name: string, label: string) {
  tabs.value.push({ name, label })
  // Set first tab as active by default
  if (tabs.value.length === 1) {
    activeTab.value = name
  }
}

// Unregister a tab
function unregisterTab(name: string) {
  const index = tabs.value.findIndex(tab => tab.name === name)
  if (index !== -1) {
    tabs.value.splice(index, 1)
    // If active tab is removed, activate first remaining tab
    if (activeTab.value === name && tabs.value.length > 0) {
      activeTab.value = tabs.value[0].name
    }
  }
}

// Method to change active tab
function setActiveTab(tabName: string) {
  activeTab.value = tabName
}

/**
 * Start dragging a tab header.
 */
function onDragStart(event: DragEvent, index: number) {
  // Enable moving ghost image and allow drop by setting drag data
  if (event.dataTransfer) {
    event.dataTransfer.effectAllowed = 'move'
    event.dataTransfer.setData('text/plain', '')
    // Use the element itself as drag image so it follows cursor
    event.dataTransfer.setDragImage(event.currentTarget as HTMLElement, 0, 0)
  }
  draggingIndex.value = index
}

/**
 * Allow dropping by preventing default.
 */
/**
 * Highlight the current drop target index.
 */
/**
 * Compute drop slot index by comparing cursor x against tab midpoints.
 */
function onDragOverContainer(event: DragEvent) {
  event.preventDefault()
  const headers = event.currentTarget as HTMLElement
  // Only consider the draggable tab buttons (exclude the add-tab button)
  // Compute drop slot by checking midpoints of each actual tab button
  const btnEls = Array.from(
    headers.querySelectorAll<HTMLButtonElement>('.tab-button:not(.add-tab)')
  )
  for (let i = 0; i < btnEls.length; i++) {
    const btn = btnEls[i]
    if (!btn) continue
    const rect = btn.getBoundingClientRect()
    if (event.clientX < rect.left + rect.width / 2) {
      dragOverIndex.value = i
      return
    }
  }
  // Past all tabs => drop at end
  dragOverIndex.value = btnEls.length
}

/**
 * Drop a tab header and reorder the tabs.
 */
/**
 * Drop a tab header according to the last dragOverIndex slot.
 */
/**
 * Drop a tab: remove from its original position and insert into the target slot,
 * provided the drop slot skips over an adjacent boundary.
 */
function onDrop(event: DragEvent) {
  event.preventDefault()
  const from = draggingIndex.value
  const toSlot = dragOverIndex.value
  draggingIndex.value = null
  dragOverIndex.value = null
  if (from === null || toSlot === null) return
  // slight drags adjacent to original => no move
  if (toSlot === from || toSlot === from + 1) {
    return
  }
  // remove the tab and re-insert at new slot
  const moved = tabs.value.splice(from, 1)[0]
  const dest = toSlot > from ? toSlot - 1 : toSlot
  tabs.value.splice(dest, 0, moved)
}

/**
 * Clear dragging state on drag end (abort).
 */
function onDragEnd() {
  draggingIndex.value = null
  dragOverIndex.value = null
}

// Provide tab context to child components
provide(tabInjectKey, {
  activeTab,
  registerTab,
  unregisterTab
})

// Expose control methods to parent via template ref
defineExpose({ setActiveTab, activeTab })

// Expose drag-drop helpers to the template
</script>

<template>
  <div class="tabs-container">
    <!-- Tab headers (draggable to reorder) -->
    <div class="tab-headers" @dragover="onDragOverContainer" @drop="onDrop">
      <template v-for="(tab, idx) in tabs" :key="tab.name">
        <!-- drop indicator before this slot -->
        <div v-if="draggingIndex !== null && dragOverIndex === idx" class="drop-indicator" />
        <button
          class="tab-button"
          :class="{ active: activeTab === tab.name }"
          @click="setActiveTab(tab.name)"
          draggable="true"
          @dragstart="e => onDragStart(e, idx)"
          @dragend="onDragEnd"
        >
          {{ tab.label }}
        </button>
      </template>
      <!-- drop indicator at end -->
      <div v-if="draggingIndex !== null && dragOverIndex === tabs.length" class="drop-indicator" />
      <!-- Add-new-tab button -->
      <button class="tab-button add-tab" draggable="false" @click="emit('add-tab')">+</button>
    </div>

    <!-- Tab content area -->
    <div class="tab-content">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.tabs-container {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.tab-headers {
  display: flex;
  position: relative;
}

.tab-button {
  padding: 0.5rem 1rem;
  border-radius: 0px;
  border-top-left-radius: 5px;
  border-top-right-radius: 5px;
  color: var(--inactive-tab-title);
  background: none;
  border: none;
  cursor: grab;
  transition: all 0.2s ease;
}

.tab-button:hover {
  background-color: var(--orange);
}

.tab-button.active {
  background: var(--code-editor-background);
  color: white;
  cursor: grabbing;
}

.tab-content {
  min-height: 0;
  flex-grow: 1;
}

/* Visual drop indicator bar */
.drop-indicator {
  width: 2px;
  background: white;
  margin: 0 4px;
  align-self: stretch;
}

/* Add-tab button styling */
.tab-button.add-tab {
  font-size: 1.2em;
  padding: 0 0.6rem;
  background-color: var(--code-editor-background);
  color: var(--inactive-tab-title);
  cursor: pointer;
}

.tab-button.add-tab:hover {
  background-color: var(--orange);
}

/* Add-tab button styling */
.tab-button.add-tab {
  font-size: 1.2em;
  padding: 0 0.6rem;
  background-color: var(--code-editor-background);
  color: var(--inactive-tab-title);
}
</style>