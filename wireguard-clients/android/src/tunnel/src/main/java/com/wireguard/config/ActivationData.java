package com.wireguard.config;

import com.wireguard.config.BadConfigException.Location;
import com.wireguard.config.BadConfigException.Reason;
import com.wireguard.config.BadConfigException.Section;
import com.wireguard.crypto.Key;
import com.wireguard.crypto.KeyFormatException;
import com.wireguard.util.NonNullForAll;

import java.util.Locale;
import java.util.Objects;

import androidx.annotation.Nullable;
@NonNullForAll
public final class  ActivationData {
    private final InetEndpoint host;
    private final Key publicKey;

    private ActivationData(final Builder builder) {
        host = builder.host;
        publicKey = builder.publicKey;
    }

    public static ActivationData parse(final Iterable<? extends CharSequence> lines)
            throws BadConfigException {
        final Builder builder = new Builder();
        for (final CharSequence line : lines) {
            final Attribute attribute = Attribute.parse(line).orElseThrow(() ->
                    new BadConfigException(Section.ACTIVATION, Location.TOP_LEVEL,
                            Reason.SYNTAX_ERROR, line));
            switch (attribute.getKey().toLowerCase(Locale.ENGLISH)) {
                case "host":
                    builder.parseActivationHost(attribute.getValue());
                    break;
                case "key":
                    builder.parsePublicKey(attribute.getValue());
                    break;
                default:
                    throw new BadConfigException(Section.ACTIVATION, Location.TOP_LEVEL,
                            Reason.UNKNOWN_ATTRIBUTE, attribute.getKey());
            }
        }
        return builder.build();
    }

    @Override
    public boolean equals(final Object obj) {
        if (!(obj instanceof ActivationData))
            return false;
        final ActivationData other = (ActivationData) obj;
        return  host.equals(other.host)
                && publicKey.equals(other.getPublicKey());
    }


    /**
     * Returns the peer's endpoint.
     *
     * @return the endpoint, or {@code Optional.empty()} if none is configured
     */
    public InetEndpoint getHost() {
        return host;
    }

    /**
     * Returns the peer's public key.
     *
     * @return the public key
     */
    public Key getPublicKey() {
        return publicKey;
    }

    @Override
    public int hashCode() {
        int hash = 1;
        hash = 31 * hash + host.hashCode();
        hash = 31 * hash + publicKey.hashCode();
        return hash;
    }

    /**
     * Converts the {@code Peer} into a string suitable for debugging purposes. The {@code Peer} is
     * identified by its public key and (if known) its endpoint.
     *
     * @return a concise single-line identifier for the {@code Peer}
     */
    @Override
    public String toString() {
        if(publicKey == null || host == null) {
            return "";
        }
        final StringBuilder sb = new StringBuilder();
        sb.append("[Config]").append('\n');
        sb.append("host = ").append(host).append('\n');
        sb.append("key = ").append(publicKey.toBase64()).append('\n');
        return sb.toString();
    }

    public String toWgUserspaceString() {
        return "";
    }

    @SuppressWarnings("UnusedReturnValue")
    public static final class Builder {
        @Nullable private Key publicKey;
        @Nullable private InetEndpoint host;


        public ActivationData build(){
            return new ActivationData(this);
        }

        public Builder parseActivationHost(final String endpoint) throws BadConfigException {
            try {
                return setActivationHost(InetEndpoint.parse(endpoint));
            } catch (final ParseException e) {
                throw new BadConfigException(Section.ACTIVATION, Location.ENDPOINT, e);
            }
        }

        public Builder parsePublicKey(final String publicKey) throws BadConfigException {
            try {
                return setPublicKey(Key.fromBase64(publicKey));
            } catch (final KeyFormatException e) {
                throw new BadConfigException(Section.CONFIG, Location.PUBLIC_KEY, e);
            }
        }

        public Builder setActivationHost(final InetEndpoint endpoint) {
            host = endpoint;
            return this;
        }

        public Builder setPublicKey(final Key publicKey) {
            this.publicKey = publicKey;
            return this;
        }
    }
}