---
layout: false
---

<script setup>
import { onMounted } from 'vue'
import versionsConfig from '../../versions.json'

onMounted(() => {
  window.location.href = `/en/${versionsConfig.latest}/`
})
</script>

<template>
  <div>Redirecting to latest version...</div>
</template>