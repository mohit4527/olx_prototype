import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.gradle.jvm.toolchain.JavaLanguageVersion
import org.gradle.jvm.toolchain.JavaToolchainService
import org.jetbrains.kotlin.gradle.dsl.KotlinJvmProjectExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Ensure Kotlin compilation uses JVM target 11 across all modules (fixes mismatched jvmTarget errors)
subprojects {
    afterEvaluate {
        tasks.withType(KotlinCompile::class.java).configureEach {
            kotlinOptions.jvmTarget = "11"
        }
    }
}

// Ensure Java compilation also targets Java 11 across all modules to avoid
// inconsistent JVM target compatibility between Kotlin and Java tasks.
subprojects {
    afterEvaluate {
        tasks.withType(org.gradle.api.tasks.compile.JavaCompile::class.java).configureEach {
            sourceCompatibility = "11"
            targetCompatibility = "11"
        }
    }
}

// Configure Kotlin JVM toolchain to use Java 11 for all Kotlin projects.
// This ensures the Kotlin compiler produces class files compatible with Java 11
// and avoids the 'Inconsistent JVM-target compatibility' error.
subprojects {
    plugins.withType(org.jetbrains.kotlin.gradle.plugin.KotlinBasePluginWrapper::class.java).configureEach {
        extensions.findByType(KotlinJvmProjectExtension::class.java)?.apply {
            jvmToolchain {
                languageVersion.set(JavaLanguageVersion.of(11))
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
// After all projects are evaluated, enforce Java/Kotlin JVM targets to 11.
// This helps override plugin-level settings (for example, some pub plugins)
// that may set Java compatibility to 1.8 and cause the JVM-target mismatch.
gradle.projectsEvaluated {
    allprojects.forEach { proj ->
        // Only configure Java/Kotlin compile tasks for Android projects. Some included builds
        // or plugins (in pub-cache) are not Android libraries/apps and configuring their
        // JavaCompile tasks can remove the Android boot classpath, causing android.* types
        // to be missing. Check whether the Android plugin is applied before changing tasks.
        if (proj.plugins.hasPlugin("com.android.library") || proj.plugins.hasPlugin("com.android.application")) {
            proj.tasks.withType(org.gradle.api.tasks.compile.JavaCompile::class.java).configureEach {
                sourceCompatibility = "11"
                targetCompatibility = "11"
            }

            proj.tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
                kotlinOptions.jvmTarget = "11"
            }

            proj.plugins.withType(org.jetbrains.kotlin.gradle.plugin.KotlinBasePluginWrapper::class.java).configureEach {
                proj.extensions.findByType(org.jetbrains.kotlin.gradle.dsl.KotlinJvmProjectExtension::class.java)?.apply {
                    jvmToolchain {
                        languageVersion.set(org.gradle.jvm.toolchain.JavaLanguageVersion.of(11))
                    }
                }
            }
        }

        proj.tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
            kotlinOptions.jvmTarget = "11"
        }

        proj.plugins.withType(org.jetbrains.kotlin.gradle.plugin.KotlinBasePluginWrapper::class.java).configureEach {
            proj.extensions.findByType(org.jetbrains.kotlin.gradle.dsl.KotlinJvmProjectExtension::class.java)?.apply {
                jvmToolchain {
                    languageVersion.set(org.gradle.jvm.toolchain.JavaLanguageVersion.of(11))
                }
            }
        }
    }
}
plugins {
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false

    id("com.google.gms.google-services") version "4.3.15" apply false
}
