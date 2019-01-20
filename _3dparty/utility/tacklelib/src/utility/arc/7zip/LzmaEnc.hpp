#pragma once

#include <src/tacklelib_private.hpp>

#if ERROR_IF_EMPTY_PP_DEF(USE_UTILITY_ARC_7ZIP_LZMA_ENCODER)

#include <tacklelib/utility/platform.hpp>
#include <tacklelib/utility/debug.hpp>
#include <tacklelib/utility/assert.hpp>

#include <tacklelib/tackle/smart_handle.hpp>

#include <fmt/format.h>

#include <LzmaDec.h>
#include <LzmaEnc.h>

#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <stdexcept>
#include <string>


namespace utility {
namespace arc {
namespace _7zip {

    class LzmaEncoderHandle;

    LzmaEncoderHandle create_lzma_encoder(ISzAllocPtr alloc);

    class LzmaEncoderHandle : public tackle::SmartHandle<ISzAlloc>
    {
        friend LzmaEncoderHandle create_lzma_encoder(ISzAllocPtr alloc);

        using base_type = SmartHandle;

    public:
        static FORCE_INLINE const LzmaEncoderHandle & null()
        {
            static const LzmaEncoderHandle s_null = LzmaEncoderHandle{ nullptr, nullptr };
            return s_null;
        }

    private:
        struct Deleter
        {
            FORCE_INLINE Deleter(ISzAllocPtr palloc) :
                m_palloc(palloc)
            {
            }

            FORCE_INLINE Deleter(const Deleter &) = default;

            FORCE_INLINE void operator()(ISzAlloc * p) const
            {
                if (p) {
                    LzmaEnc_Destroy(static_cast<CLzmaEncHandle>(p), m_palloc, m_palloc);
                }
            }

            ISzAllocPtr m_palloc;
        };

    public:
        FORCE_INLINE LzmaEncoderHandle()
        {
            *this = null();
        }

        FORCE_INLINE LzmaEncoderHandle(const LzmaEncoderHandle &) = default;

    private:
        FORCE_INLINE LzmaEncoderHandle(CLzmaEncHandle p, ISzAllocPtr palloc) :
            base_type(p, Deleter{ palloc }),
            m_palloc(palloc)
        {
        }

    public:
        FORCE_INLINE void reset(const LzmaEncoderHandle & handle = LzmaEncoderHandle::null())
        {
            auto * deleter = DEBUG_VERIFY_TRUE(std::get_deleter<base_type::DeleterType>(handle.m_pv));
            if (!deleter) {
                // must always have a deleter
                DEBUG_BREAK_THROW(true) std::runtime_error(
                    fmt::format("{:s}({:d}): deleter is not allocated",
                        UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
            }

            base_type::reset(handle.get(), *deleter);
            m_palloc = handle.m_palloc;
        }

        FORCE_INLINE CLzmaEncHandle get() const
        {
            return base_type::get();
        }

        FORCE_INLINE ISzAllocPtr get_allocator() const
        {
            return m_palloc;
        }

        FORCE_INLINE SRes encode(ISeqOutStream * outStream, ISeqInStream * inStream, uint64_t file_size, ICompressProgress * progress);

    private:
        ISzAllocPtr m_palloc;
    };

    //// globals

    FORCE_INLINE LzmaEncoderHandle create_lzma_encoder(ISzAllocPtr alloc)
    {
        CLzmaEncHandle enc = LzmaEnc_Create(alloc);
        if (!enc) {
            LzmaEncoderHandle{};
        }

        return LzmaEncoderHandle{ static_cast<struct CLzmaEnc *>(LzmaEnc_Create(alloc)), alloc };
    }

    //// LzmaEncoderHandle

    FORCE_INLINE SRes LzmaEncoderHandle::encode(ISeqOutStream * out_stream, ISeqInStream * in_stream, uint64_t file_size, ICompressProgress * progress)
    {
        CLzmaEncHandle enc = get();
        if (!enc) {
            DEBUG_BREAK_THROW(true) std::runtime_error(
                fmt::format("{:s}({:d}): encoder is not allocated",
                    UTILITY_PP_FUNCSIG, UTILITY_PP_LINE));
        }

        CLzmaEncProps props;
        LzmaEncProps_Init(&props);

        SRes res = LzmaEnc_SetProps(enc, &props);
        if (res == SZ_OK) {
            Byte header[LZMA_PROPS_SIZE + 8];
            size_t headerSize = LZMA_PROPS_SIZE;

            res = LzmaEnc_WriteProperties(enc, header, &headerSize);
            if (res == SZ_OK) {
                for (int i = 0; i < 8; i++) {
                    header[headerSize++] = (Byte)(file_size >> (8 * i));
                }
                if (out_stream->Write(out_stream, header, headerSize) == headerSize)
                {
                    if (res == SZ_OK)
                        res = LzmaEnc_Encode(enc, out_stream, in_stream, progress, m_palloc, m_palloc);
                }
                else {
                    res = SZ_ERROR_WRITE;
                }
            }
        }

        return res;
    }

}
}
}

#endif
