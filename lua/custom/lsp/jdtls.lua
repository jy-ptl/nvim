local J = {}

function J.setup()
  local jdtls = require 'jdtls'

  -- Derive workspace directory name from project directory
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
  local workspace_dir = vim.fn.stdpath 'data' .. '/eclipse/' .. project_name

  -- Base installation path for jdtls installed via Mason
  local jdtls_install_path = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'

  -- Find the correct launcher jar dynamically
  local launcher_path = vim.fn.glob(jdtls_install_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

  -- Detect config directory based on system architecture
  local uname = vim.loop.os_uname().machine
  local config_name = (uname == 'aarch64' or uname == 'arm64') and 'config_linux_arm' or 'config_linux'
  local config_path = jdtls_install_path .. '/' .. config_name

  -- Path to Lombok (if using)
  local lombok_path = jdtls_install_path .. '/lombok.jar'

  -- LSP settings for Java.
  local on_attach = function(_, bufnr)
    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
  end

  -- Final config
  local config = {
    cmd = {
      'java',
      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      '-Xmx1g',
      '-javaagent:' .. lombok_path,
      '--add-modules=ALL-SYSTEM',
      '--add-opens',
      'java.base/java.util=ALL-UNNAMED',
      '--add-opens',
      'java.base/java.lang=ALL-UNNAMED',
      '-jar',
      launcher_path,
      '-configuration',
      config_path,
      '-data',
      workspace_dir,
    },

    root_dir = vim.fs.root(0, { '.git', 'mvnw', 'gradlew' }),

    settings = {
      java = {
        references = {
          includeDecompiledSources = true,
        },
        format = {
          enabled = true,
          settings = {
            url = vim.fn.stdpath 'config' .. '/lang_servers/intellij-java-google-style.xml',
            profile = 'GoogleStyle',
          },
        },
        eclipse = {
          downloadSources = true,
        },
        maven = {
          downloadSources = true,
        },
        signatureHelp = { enabled = true },
        contentProvider = { preferred = 'fernflower' },
        -- eclipse = {
        -- 	downloadSources = true,
        -- },
        -- implementationsCodeLens = {
        -- 	enabled = true,
        -- },
        completion = {
          favoriteStaticMembers = {
            'org.hamcrest.MatcherAssert.assertThat',
            'org.hamcrest.Matchers.*',
            'org.hamcrest.CoreMatchers.*',
            'org.junit.jupiter.api.Assertions.*',
            'java.util.Objects.requireNonNull',
            'java.util.Objects.requireNonNullElse',
            'org.mockito.Mockito.*',
          },
          filteredTypes = {
            'com.sun.*',
            'io.micrometer.shaded.*',
            'java.awt.*',
            'jdk.*',
            'sun.*',
          },
          importOrder = {
            'java',
            'javax',
            'com',
            'org',
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 5,
            staticStarThreshold = 3,
          },
        },
        codeGeneration = {
          toString = {
            template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
            -- flags = {
            -- 	allow_incremental_sync = true,
            -- },
          },
          useBlocks = true,
        },
        -- configuration = {
        --     runtimes = {
        --         {
        --             name = "java-17-openjdk",
        --             path = "/usr/lib/jvm/default-runtime/bin/java"
        --         }
        --     }
        -- }
        -- project = {
        -- 	referencedLibraries = {
        -- 		"**/lib/*.jar",
        -- 	},
        -- },
      },
    },

    flags = {
      allow_incremental_sync = true,
    },
  }

  config.on_attach = on_attach

  config.on_init = function(client, _)
    client.notify('workspace/didChangeConfiguration', { settings = config.settings })
  end

  local extendedClientCapabilities = require('jdtls').extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  config.init_options = {
    extendedClientCapabilities = extendedClientCapabilities,
  }

  jdtls.start_or_attach(config)
end

return J
