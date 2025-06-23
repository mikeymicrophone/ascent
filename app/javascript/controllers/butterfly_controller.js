import { Controller } from "@hotwired/stimulus"

// Butterfly Navigation Controller
// Connects to data-controller="butterfly"
export default class extends Controller {
  static targets = ["container"]
  static values = { 
    level: String,
    enabled: { type: Boolean, default: true },
    logLevel: { type: String, default: "info" }
  }

  connect() {
    this.butterfly = null
    this.trail = []
    this.maxTrailLength = 8
    this.isFlying = false
    
    // Store reference for global debugging
    window.butterflyControllerInstance = this
    
    // Set up global debug methods on first connection
    if (!window.debugButterfly) {
      this.constructor.addGlobalDebugMethods()
    }
    
    this.debug('[Butterfly] Controller connected', {
      level: this.levelValue,
      enabled: this.enabledValue,
      logLevel: this.logLevelValue,
      element: this.element
    })
    
    if (this.enabledValue) {
      this.createButterfly()
      this.bindEvents()
    }
  }

  disconnect() {
    this.cleanup()
  }

  createButterfly() {
    // Create butterfly element
    this.butterfly = document.createElement('div')
    // Start hidden and without the 'flying' class.
    this.butterfly.className = `navigation-butterfly hidden level-${this.levelValue || 'topic'}`
    this.butterfly.id = `butterfly-${Date.now()}`
    
    // Create butterfly structure
    this.butterfly.innerHTML = `
      <div class="butterfly-body"></div>
      <div class="butterfly-wing-left"></div>
      <div class="butterfly-wing-right"></div>
    `
    
    document.body.appendChild(this.butterfly)

    // Set initial position to avoid it appearing at (0,0)
    const initialPosition = this.getCurrentPosition()
    this.butterfly.style.left = `${initialPosition.x}px`
    this.butterfly.style.top = `${initialPosition.y}px`
    this.butterfly.style.transform = 'translate(-50%, -50%)'

    this.info('[Butterfly] Created butterfly', {
      level: this.levelValue,
      element: this.butterfly,
      id: this.butterfly.id,
      className: this.butterfly.className,
      initialPosition: initialPosition
    })
    
    this.debugButterflyState('after creation')
  }

  bindEvents() {
    // Listen for navigation clicks on expandable headers and links
    document.addEventListener('click', this.handleNavigationClick.bind(this))
    
    // Listen for mouse movement to create subtle following effect
    document.addEventListener('mousemove', this.handleMouseMove.bind(this))
    
    // Listen for expandable state changes
    document.addEventListener('expandable:opened', this.handleExpandableOpened.bind(this))
    document.addEventListener('expandable:closed', this.handleExpandableClosed.bind(this))
  }

  handleNavigationClick(event) {
    if (!this.enabledValue || this.isFlying) return
    
    const target = event.target.closest('.expandable-header, .link, a[href]')
    if (!target) return
    
    // Determine navigation level and destination
    const level = this.determineNavigationLevel(target)
    const destination = this.getDestinationPosition(target)
    
    if (destination) {
      this.flyTo(destination, level)
    }
  }

  handleMouseMove(event) {
    if (!this.enabledValue || this.isFlying) return
    
    // Subtle butterfly following effect (much slower than direct movement)
    const mouseX = event.clientX
    const mouseY = event.clientY
    
    // Only follow if mouse is near navigation elements
    const navElement = event.target.closest('.expandable-header, .navigation, .breadcrumb-chain')
    if (navElement && this.butterfly) {
      this.subtleFollow(mouseX, mouseY)
    }
  }

  handleExpandableOpened(event) {
    if (!this.enabledValue) return
    
    const expandableContent = event.target.querySelector('.expandable-content')
    if (expandableContent) {
      const rect = expandableContent.getBoundingClientRect()
      const centerX = rect.left + rect.width / 2
      const centerY = rect.top + rect.height / 2
      
      this.flyTo({ x: centerX, y: centerY }, 'expanded')
    }
  }

  handleExpandableClosed(event) {
    if (!this.enabledValue) return
    
    // Fly back to header when collapsed
    const header = event.target.querySelector('.expandable-header')
    if (header) {
      const destination = this.getDestinationPosition(header)
      if (destination) {
        this.flyTo(destination, 'collapsed')
      }
    }
  }

  determineNavigationLevel(element) {
    // Determine hierarchy level based on element context
    if (element.closest('.country-partial')) return 'country'
    if (element.closest('.state-partial')) return 'state'
    if (element.closest('.city-partial')) return 'city'
    if (element.closest('.topic-partial')) return 'topic'
    if (element.closest('.issue-partial')) return 'issue'
    if (element.closest('.approach-partial')) return 'approach'
    if (element.closest('.election-partial')) return 'election'
    
    return this.levelValue || 'topic'
  }

  getDestinationPosition(element) {
    const rect = element.getBoundingClientRect()
    
    // Use viewport coordinates for fixed positioning
    return {
      x: rect.left + rect.width / 2,
      y: rect.top + rect.height / 2
    }
  }

  flyTo(destination, level) {
    if (!this.butterfly || this.isFlying) {
      this.warn('[Butterfly] Cannot fly', {
        hasButterfly: !!this.butterfly,
        isFlying: this.isFlying,
        destination,
        level
      })
      return
    }
    
    this.isFlying = true
    this.showButterfly()
    
    // Update butterfly level styling
    this.butterfly.className = `navigation-butterfly flying level-${level}`
    
    // Calculate flight path (bezier curve for natural movement)
    const start = this.getCurrentPosition()
    const controlPoint = this.calculateControlPoint(start, destination)
    
    this.info('[Butterfly] Starting flight', {
      from: start,
      to: destination,
      via: controlPoint,
      level: level,
      butterflyState: this.getButterflyState()
    })
    
    this.debugButterflyState('before flight')
    
    // Animate along bezier curve
    this.animateAlongPath(start, controlPoint, destination, level)
  }

  getCurrentPosition() {
    if (!this.butterfly) return { x: window.innerWidth / 2, y: window.innerHeight / 2 }
    
    const rect = this.butterfly.getBoundingClientRect()
    
    // Use viewport coordinates for fixed positioning
    return {
      x: rect.left + rect.width / 2,
      y: rect.top + rect.height / 2
    }
  }

  calculateControlPoint(start, end) {
    // Create a natural arc for the butterfly flight
    const midX = (start.x + end.x) / 2
    const midY = (start.y + end.y) / 2
    
    // Add some randomness and arc height
    const arcHeight = Math.min(100, Math.abs(end.y - start.y) * 0.5)
    const randomOffset = (Math.random() - 0.5) * 60
    
    return {
      x: midX + randomOffset,
      y: midY - arcHeight
    }
  }

  animateAlongPath(start, control, end, level) {
    const duration = 1200 // 1.2 seconds
    const startTime = performance.now()
    
    const animate = (currentTime) => {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)
      
      // Ease-out cubic for natural deceleration
      const easeProgress = 1 - Math.pow(1 - progress, 3)
      
      // Calculate position on bezier curve
      const position = this.bezierPoint(start, control, end, easeProgress)
      
      // Update butterfly position
      if (this.butterfly) {
        this.butterfly.style.left = `${position.x}px`
        this.butterfly.style.top = `${position.y}px`
        
        // Add rotation based on movement direction
        const rotation = this.calculateRotation(start, end, easeProgress)
        this.butterfly.style.transform = `translate(-50%, -50%) rotate(${rotation}deg)`
      }
      
      // Create sparkle trail
      if (progress > 0.1 && progress < 0.9) {
        this.createTrailSparkle(position)
      }
      
      if (progress < 1) {
        requestAnimationFrame(animate)
      } else {
        this.finishFlight(level)
      }
    }
    
    requestAnimationFrame(animate)
  }

  bezierPoint(start, control, end, t) {
    const x = Math.pow(1 - t, 2) * start.x + 2 * (1 - t) * t * control.x + Math.pow(t, 2) * end.x
    const y = Math.pow(1 - t, 2) * start.y + 2 * (1 - t) * t * control.y + Math.pow(t, 2) * end.y
    return { x, y }
  }

  calculateRotation(start, end, progress) {
    const dx = end.x - start.x
    const dy = end.y - start.y
    const angle = Math.atan2(dy, dx) * (180 / Math.PI)
    
    // Add some flutter variation
    const flutter = Math.sin(progress * Math.PI * 8) * 5
    return angle + flutter
  }

  createTrailSparkle(position) {
    const sparkle = document.createElement('div')
    sparkle.className = 'butterfly-trail sparkle'
    sparkle.style.left = `${position.x}px`
    sparkle.style.top = `${position.y}px`
    
    document.body.appendChild(sparkle)
    
    // Remove sparkle after animation
    setTimeout(() => {
      if (sparkle.parentNode) {
        sparkle.parentNode.removeChild(sparkle)
      }
    }, 1000)
    
    // Limit trail length
    this.trail.push(sparkle)
    if (this.trail.length > this.maxTrailLength) {
      const oldSparkle = this.trail.shift()
      if (oldSparkle && oldSparkle.parentNode) {
        oldSparkle.parentNode.removeChild(oldSparkle)
      }
    }
  }

  finishFlight(level) {
    this.isFlying = false
    
    if (this.butterfly) {
      // Celebration animation
      this.butterfly.classList.add('arrived')
      
      setTimeout(() => {
        if (this.butterfly) {
          this.butterfly.classList.remove('arrived')
          this.hideButterfly()
        }
      }, 1000)
    }
    
    console.log('[Butterfly] Arrived at', level)
  }

  subtleFollow(mouseX, mouseY) {
    if (!this.butterfly || this.isFlying) return
    
    const current = this.getCurrentPosition()
    const distance = Math.sqrt(Math.pow(mouseX - current.x, 2) + Math.pow(mouseY - current.y, 2))
    
    // Only follow if mouse is reasonably close and moving
    if (distance > 50 && distance < 300) {
      const followX = current.x + (mouseX - current.x) * 0.1
      const followY = current.y + (mouseY - current.y) * 0.1
      
      this.butterfly.style.left = `${followX}px`
      this.butterfly.style.top = `${followY}px`
    }
  }

  showButterfly() {
    if (this.butterfly) {
      this.butterfly.classList.remove('hidden')
      this.butterfly.classList.add('flying')
    }
  }

  hideButterfly() {
    if (this.butterfly) {
      this.butterfly.classList.remove('flying')
      // Stay visible longer to appreciate the animation
      setTimeout(() => {
        if (this.butterfly) {
          this.butterfly.classList.add('hidden')
        }
      }, 3000) // Hide after 3 seconds
    }
  }

  cleanup() {
    if (this.butterfly && this.butterfly.parentNode) {
      this.butterfly.parentNode.removeChild(this.butterfly)
    }
    
    // Clean up trail sparkles
    this.trail.forEach(sparkle => {
      if (sparkle && sparkle.parentNode) {
        sparkle.parentNode.removeChild(sparkle)
      }
    })
    
    this.trail = []
  }

  // Public methods for external control
  enable() {
    this.enabledValue = true
    if (!this.butterfly) {
      this.createButterfly()
    }
  }

  disable() {
    this.enabledValue = false
    this.hideButterfly()
  }

  changeLevel(newLevel) {
    this.levelValue = newLevel
    if (this.butterfly) {
      this.butterfly.className = `navigation-butterfly hidden level-${newLevel}`
    }
  }

  // =============================================================================
  // DEBUGGING AND LOGGING METHODS
  // =============================================================================

  // Logging methods that respect log level
  debug(message, data = null) {
    if (this.shouldLog('debug')) {
      console.log(message, data)
    }
  }

  info(message, data = null) {
    if (this.shouldLog('info')) {
      console.log(message, data)
    }
  }

  warn(message, data = null) {
    if (this.shouldLog('warn')) {
      console.warn(message, data)
    }
  }

  error(message, data = null) {
    if (this.shouldLog('error')) {
      console.error(message, data)
    }
  }

  shouldLog(level) {
    const levels = ['debug', 'info', 'warn', 'error']
    const currentLevelIndex = levels.indexOf(this.logLevelValue)
    const requestedLevelIndex = levels.indexOf(level)
    return requestedLevelIndex >= currentLevelIndex
  }

  // Get complete butterfly state for debugging
  getButterflyState() {
    if (!this.butterfly) return { exists: false }

    const rect = this.butterfly.getBoundingClientRect()
    const computedStyle = window.getComputedStyle(this.butterfly)
    
    return {
      exists: true,
      id: this.butterfly.id,
      className: this.butterfly.className,
      isFlying: this.isFlying,
      position: {
        viewport: {
          left: rect.left,
          top: rect.top,
          right: rect.right,
          bottom: rect.bottom,
          width: rect.width,
          height: rect.height
        },
        center: {
          x: rect.left + rect.width / 2,
          y: rect.top + rect.height / 2
        },
        css: {
          left: computedStyle.left,
          top: computedStyle.top,
          transform: computedStyle.transform,
          position: computedStyle.position
        }
      },
      visibility: {
        display: computedStyle.display,
        visibility: computedStyle.visibility,
        opacity: computedStyle.opacity,
        zIndex: computedStyle.zIndex
      },
      size: {
        width: computedStyle.width,
        height: computedStyle.height
      },
      inDOM: document.body.contains(this.butterfly),
      trail: this.trail.length
    }
  }

  // Debug butterfly state with optional context
  debugButterflyState(context = '') {
    const state = this.getButterflyState()
    this.debug(`[Butterfly] State ${context}:`, state)
    return state
  }

  // Check if butterfly is visible to user
  isButterflyVisible() {
    if (!this.butterfly) return false
    
    const rect = this.butterfly.getBoundingClientRect()
    const computedStyle = window.getComputedStyle(this.butterfly)
    
    const isInViewport = rect.top >= 0 && 
                        rect.left >= 0 && 
                        rect.bottom <= window.innerHeight && 
                        rect.right <= window.innerWidth
    
    const isVisible = computedStyle.display !== 'none' && 
                     computedStyle.visibility !== 'hidden' && 
                     parseFloat(computedStyle.opacity) > 0
    
    const result = {
      inViewport: isInViewport,
      cssVisible: isVisible,
      fullyVisible: isInViewport && isVisible,
      rect: rect,
      style: {
        display: computedStyle.display,
        visibility: computedStyle.visibility,
        opacity: computedStyle.opacity
      }
    }
    
    this.debug('[Butterfly] Visibility check:', result)
    return result
  }

  // Force butterfly to be visible for debugging
  forceVisible() {
    if (!this.butterfly) {
      this.warn('[Butterfly] Cannot force visible - no butterfly exists')
      return
    }
    
    this.butterfly.style.display = 'block'
    this.butterfly.style.visibility = 'visible'
    this.butterfly.style.opacity = '1'
    this.butterfly.style.zIndex = '9999'
    this.butterfly.style.backgroundColor = 'red'
    this.butterfly.style.border = '3px solid blue'
    
    this.info('[Butterfly] Forced visible with debug styling')
    this.debugButterflyState('after force visible')
  }

  // Reset butterfly to center of screen for debugging
  centerButterfly() {
    if (!this.butterfly) {
      this.warn('[Butterfly] Cannot center - no butterfly exists')
      return
    }
    
    this.butterfly.style.left = '50%'
    this.butterfly.style.top = '50%'
    this.butterfly.style.transform = 'translate(-50%, -50%)'
    
    this.info('[Butterfly] Centered butterfly')
    this.debugButterflyState('after centering')
  }

  // Global debugging methods accessible from console
  static addGlobalDebugMethods() {
    window.debugButterfly = {
      findController: () => {
        return window.butterflyControllerInstance || null
      },
      
      getState: () => {
        const controller = window.debugButterfly.findController()
        return controller ? controller.getButterflyState() : 'No butterfly controller found'
      },
      
      checkVisibility: () => {
        const controller = window.debugButterfly.findController()
        return controller ? controller.isButterflyVisible() : 'No butterfly controller found'
      },
      
      forceVisible: () => {
        const controller = window.debugButterfly.findController()
        if (controller) {
          controller.forceVisible()
          return 'Butterfly forced visible'
        }
        return 'No butterfly controller found'
      },
      
      center: () => {
        const controller = window.debugButterfly.findController()
        if (controller) {
          controller.centerButterfly()
          return 'Butterfly centered'
        }
        return 'No butterfly controller found'
      },
      
      setLogLevel: (level) => {
        const controller = window.debugButterfly.findController()
        if (controller) {
          controller.logLevelValue = level
          return `Log level set to ${level}`
        }
        return 'No butterfly controller found'
      }
    }
  }
}